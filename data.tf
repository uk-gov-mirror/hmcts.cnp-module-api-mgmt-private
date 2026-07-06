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

data "azurerm_user_assigned_identity" "uami" {
  count               = var.user_assigned_managed_identity_name != null ? 1 : 0
  name                = var.user_assigned_managed_identity_name
  resource_group_name = var.user_assigned_managed_identity_resource_group
}
