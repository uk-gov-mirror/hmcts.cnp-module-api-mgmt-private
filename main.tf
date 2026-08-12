data "azurerm_subnet" "api-mgmt-subnet" {
  name                 = "api-management"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group
}

resource "azurerm_public_ip" "apim" {
  name                = var.custom_name != null ? "${var.custom_name}-private-pip" : "${var.department}-api-mgmt-${var.environment}-private-pip"
  resource_group_name = var.virtual_network_resource_group
  location            = var.location
  allocation_method   = "Static"
  domain_name_label   = var.custom_name != null ? "${var.custom_name}-pip" : "${var.department}-api-mgmt-${var.environment}-pip"
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

  virtual_network_configuration {
    subnet_id = data.azurerm_subnet.api-mgmt-subnet.id
  }

  identity {
    type         = var.user_assigned_managed_identity_name != null ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.user_assigned_managed_identity_name != null ? [data.azurerm_user_assigned_identity.uami[0].id] : []
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
    azurerm_public_ip.apim,
    azurerm_subnet_network_security_group_association.apim,
    azurerm_subnet_route_table_association.api-mgmt-subnet
  ]
}

resource "azurerm_role_assignment" "apim" {
  count                = var.user_assigned_managed_identity_name != null ? 0 : 1
  principal_id         = azurerm_api_management.apim.identity[0].principal_id
  scope                = data.azurerm_key_vault.main[0].id
  role_definition_name = "Key Vault Secrets User"

  depends_on = [
    azurerm_api_management.apim
  ]
}

// Required to stop resource recreation for existing apim sami use
moved {
  from = azurerm_role_assignment.apim
  to   = azurerm_role_assignment.apim[0]
}

moved {
  from = azurerm_network_security_rule.AccessRedisService
  to   = azurerm_network_security_rule.AccessRedisService[0]
}

moved {
  from = azurerm_network_security_rule.SyncCounter
  to   = azurerm_network_security_rule.SyncCounter[0]
}

moved {
  from = azurerm_network_security_rule.loadbalancer
  to   = azurerm_network_security_rule.loadbalancer[0]
}

resource "azurerm_api_management_custom_domain" "api-management-custom-domain" {
  api_management_id = azurerm_api_management.apim.id

  dynamic "gateway" {
    for_each = var.custom_gateway_hostnames != null ? var.custom_gateway_hostnames : [
      {
        host_name                    = (local.key_vault_environment == "prod") ? "${var.department}-api-mgmt.platform.hmcts.net" : "${var.department}-api-mgmt.${local.key_vault_environment}.platform.hmcts.net"
        negotiate_client_certificate = true
        default_ssl_binding          = true
      },
      {
        host_name                    = (local.key_vault_environment == "prod") ? "${var.department}-api-mgmt-appgw.platform.hmcts.net" : "${var.department}-api-mgmt-appgw.${local.key_vault_environment}.platform.hmcts.net"
        negotiate_client_certificate = true
        default_ssl_binding          = true
      },
      {
        host_name                    = (local.key_vault_environment == "prod") ? "${var.department}-mtls-api-mgmt-appgw.platform.hmcts.net" : "${var.department}-mtls-api-mgmt-appgw.${local.key_vault_environment}.platform.hmcts.net"
        negotiate_client_certificate = true
        default_ssl_binding          = true
      }
    ]
    content {
      host_name                       = gateway.value.host_name
      key_vault_id                    = local.cert_url
      negotiate_client_certificate    = gateway.value.negotiate_client_certificate
      default_ssl_binding             = gateway.value.default_ssl_binding
      ssl_keyvault_identity_client_id = var.user_assigned_managed_identity_name != null ? data.azurerm_user_assigned_identity.uami[0].client_id : null
    }
  }

  depends_on = [
    data.azurerm_key_vault_certificate.certificate,
    azurerm_api_management.apim,
    azurerm_role_assignment.apim
  ]
}

resource "azurerm_api_management_logger" "apim" {
  name                = "${local.name}-logger"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.virtual_network_resource_group
  resource_id         = module.application_insights.id

  application_insights {
    instrumentation_key = module.application_insights.instrumentation_key
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
