data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "main" {
  provider            = azurerm.acmedcdcftapps
  name                = "acme${local.acmekv}${local.acme_environment}"
  resource_group_name = "${var.department}-platform-${local.acme_environment}-rg"
}

data "azurerm_key_vault_certificate" "certificate" {
  name         = (local.key_vault_environment == "prod") ? "wildcard-${var.cert_domain}-hmcts-net" : "wildcard-${local.key_vault_environment}-${var.cert_domain}-hmcts-net"
  key_vault_id = data.azurerm_key_vault.main.id
}

data "azapi_resource" "apim_custom_properties" {
  type                   = "Microsoft.ApiManagement/service@2022-08-01"
  resource_id            = azurerm_api_management.apim.id
  response_export_values = ["properties.customProperties"]

  depends_on = [azurerm_api_management.apim]
}

data "azurerm_key_vault_certificate" "developer_portal_certificate" {
  count        = var.developer_portal != null && var.developer_portal.custom_domain != null ? 1 : 0
  name         = var.developer_portal.custom_domain.cert_name
  key_vault_id = var.developer_portal.custom_domain.key_vault_id
}

data "azurerm_key_vault_certificate" "management_certificate" {
  count        = var.management != null ? 1 : 0
  name         = var.management.cert_name
  key_vault_id = var.management.key_vault_id
}
