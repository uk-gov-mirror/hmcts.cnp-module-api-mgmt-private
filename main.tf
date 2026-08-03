data "azurerm_subnet" "api-mgmt-subnet" {
  name                 = "api-management"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group
}

resource "azurerm_public_ip" "apim" {
  name                = "${var.department}-api-mgmt-${var.environment}-private-pip"
  resource_group_name = var.virtual_network_resource_group
  location            = var.location
  allocation_method   = "Static"
  domain_name_label   = "${var.department}-api-mgmt-${var.environment}-pip"
  zones               = local.zones

  tags = var.common_tags
  sku  = "Standard"
}

resource "azurerm_api_management" "apim" {
  name                      = local.name
  location                  = var.location
  resource_group_name       = var.virtual_network_resource_group
  publisher_name            = var.publisher_name
  publisher_email           = var.publisher_email
  notification_sender_email = var.notification_sender_email
  virtual_network_type      = var.virtual_network_type

  dynamic "sign_in" {
    for_each = var.developer_portal != null && var.developer_portal.sign_in_enabled != null ? [var.developer_portal] : []
    content {
      enabled = sign_in.value.sign_in_enabled
    }
  }

  dynamic "sign_up" {
    for_each = var.developer_portal != null && var.developer_portal.sign_up != null ? [var.developer_portal] : []
    content {
      enabled = sign_up.value.sign_up.enabled
      terms_of_service {
        enabled          = sign_up.value.sign_up.terms_of_service.show_tos
        text             = sign_up.value.sign_up.terms_of_service.text
        consent_required = sign_up.value.sign_up.terms_of_service.consent_required
      }
    }
  }

  virtual_network_configuration {
    subnet_id = data.azurerm_subnet.api-mgmt-subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  zones                = local.zones
  public_ip_address_id = azurerm_public_ip.apim.id

  sku_name = local.sku_name

  security {
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled = (var.department == "sds") ? true : false
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled = (var.department == "sds") ? true : false
    triple_des_ciphers_enabled                  = (var.department == "sds") ? true : false
  }

  tags = var.common_tags

  depends_on = [
    azurerm_public_ip.apim
  ]
}

resource "azurerm_role_assignment" "apim" {
  principal_id = azurerm_api_management.apim.identity[0].principal_id
  scope        = data.azurerm_key_vault.main.id

  role_definition_name = "Key Vault Secrets User"

  depends_on = [
    azurerm_api_management.apim
  ]
}

resource "azurerm_api_management_custom_domain" "api-management-custom-domain" {
  api_management_id = azurerm_api_management.apim.id

  gateway {
    host_name                    = (local.key_vault_environment == "prod") ? "${var.department}-api-mgmt.${var.custom_top_level_domain}" : "${var.department}-api-mgmt.${local.key_vault_environment}.${var.custom_top_level_domain}"
    key_vault_id                 = local.cert_url
    negotiate_client_certificate = true
    default_ssl_binding          = true
  }

  gateway {
    host_name                    = (local.key_vault_environment == "prod") ? "${var.department}-api-mgmt-appgw.${var.custom_top_level_domain}" : "${var.department}-api-mgmt-appgw.${local.key_vault_environment}.${var.custom_top_level_domain}"
    key_vault_id                 = local.cert_url
    negotiate_client_certificate = true
    default_ssl_binding          = true
  }

  gateway {
    host_name                    = (local.key_vault_environment == "prod") ? "${var.department}-mtls-api-mgmt-appgw.${var.custom_top_level_domain}" : "${var.department}-mtls-api-mgmt-appgw.${local.key_vault_environment}.${var.custom_top_level_domain}"
    key_vault_id                 = local.cert_url
    negotiate_client_certificate = true
    default_ssl_binding          = true
  }

  dynamic "developer_portal" {
    for_each = var.developer_portal != null && var.developer_portal.custom_domain != null ? [var.developer_portal] : []
    content {
      host_name                = developer_portal.value.custom_domain.fqdn
      key_vault_certificate_id = data.azurerm_key_vault_certificate.developer_portal_certificate[0].versionless_secret_id
    }
  }

  dynamic "management" {
    for_each = var.management != null ? [var.management] : []
    content {
      host_name                = management.value.fqdn
      key_vault_certificate_id = data.azurerm_key_vault_certificate.management_certificate[0].versionless_secret_id
    }
  }

  depends_on = [
    data.azurerm_key_vault_certificate.certificate,
    azurerm_api_management.apim,
    azurerm_role_assignment.apim
  ]
}

resource "azurerm_role_assignment" "apim_app_insights" {
  scope                = module.application_insights.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_api_management.apim.identity[0].principal_id

  depends_on = [
    azurerm_api_management.apim
  ]
}

resource "azurerm_api_management_logger" "apim" {
  name                = "${local.name}-logger"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.virtual_network_resource_group
  resource_id         = module.application_insights.id

  application_insights {
    connection_string = module.application_insights.connection_string
  }

  depends_on = [
    azurerm_role_assignment.apim_app_insights
  ]
}

resource "azurerm_api_management_diagnostic" "applicationinsights" {
  identifier                = "applicationinsights"
  resource_group_name       = var.virtual_network_resource_group
  api_management_name       = azurerm_api_management.apim.name
  api_management_logger_id  = azurerm_api_management_logger.apim.id
  sampling_percentage       = var.apim_diagnostic_settings.sampling_percentage
  always_log_errors         = var.apim_diagnostic_settings.always_log_errors
  http_correlation_protocol = var.apim_diagnostic_settings.http_correlation_protocol
  verbosity                 = var.apim_diagnostic_settings.verbosity

  frontend_request {
    body_bytes = var.apim_diagnostic_settings.frontend_request_body_bytes
  }

  frontend_response {
    body_bytes = var.apim_diagnostic_settings.frontend_response_body_bytes
  }

  backend_request {
    body_bytes = var.apim_diagnostic_settings.backend_request_body_bytes
  }

  backend_response {
    body_bytes = var.apim_diagnostic_settings.backend_response_body_bytes
  }
}

resource "azapi_update_resource" "apim_disable_trusted_service_connectivity" {
  count       = var.disable_trusted_service_connectivity ? 1 : 0
  type        = "Microsoft.ApiManagement/service@2022-08-01"
  resource_id = azurerm_api_management.apim.id

  body = {
    properties = {
      customProperties = merge(
        try(data.azapi_resource.apim_custom_properties.output.properties.customProperties, {}),
        {
          "Microsoft.WindowsAzure.ApiManagement.Gateway.ManagedIdentity.DisableOverPrivilegedAccess" = "True"
        }
      )
    }
  }

  depends_on = [azurerm_api_management.apim]
}
