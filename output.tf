output "name" {
  value = azurerm_api_management.apim.name
}

output "existing_custom_properties" {
  description = "Existing custom properties before applying the DisableOverPrivilegedAccess setting"
  value       = try(data.azapi_resource.apim_custom_properties.output.properties.customProperties, {})
  sensitive   = true
}

output "custom_properties_after_update" {
  description = "Custom properties after applying the DisableOverPrivilegedAccess setting (if disable_trusted_service_connectivity is true)"
  value = var.disable_trusted_service_connectivity ? try(
    azapi_update_resource.apim_disable_trusted_service_connectivity[0].body.properties.customProperties,
    {}
  ) : {}
  sensitive = true
}

output "id" {
  value = azurerm_api_management.apim.id
}
