Terraform module to create Azure APIM Instance with Private Endpoint
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 1.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.7.0 |
| <a name="provider_azurerm.acmedcdcftapps"></a> [azurerm.acmedcdcftapps](#provider\_azurerm.acmedcdcftapps) | >= 3.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_application_insights"></a> [application\_insights](#module\_application\_insights) | git::https://github.com/hmcts/terraform-module-application-insights | 4.x |

## Resources

| Name | Type |
|------|------|
| [azapi_update_resource.apim_disable_trusted_service_connectivity](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/update_resource) | resource |
| [azurerm_api_management.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management) | resource |
| [azurerm_api_management_api.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api) | resource |
| [azurerm_api_management_api_operation.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api_operation) | resource |
| [azurerm_api_management_api_policy.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api_policy) | resource |
| [azurerm_api_management_custom_domain.api-management-custom-domain](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_custom_domain) | resource |
| [azurerm_api_management_logger.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_logger) | resource |
| [azurerm_network_security_group.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.AccessRedisService](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.SyncCounter](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.apimanagement](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.custom](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.deny](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.loadbalancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.palo](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.vpn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_route.additional_routes](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route.azure_control_plane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route.default_route](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet_network_security_group_association.apim](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.api-mgmt-subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azapi_resource.apim_custom_properties](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/resource) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_certificate.certificate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_certificate) | data source |
| [azurerm_subnet.api-mgmt-subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_routes_apim"></a> [additional\_routes\_apim](#input\_additional\_routes\_apim) | A list of additional route configurations | <pre>list(object({<br/>    name                   = string<br/>    address_prefix         = string<br/>    next_hop_type          = string<br/>    next_hop_in_ip_address = string<br/>  }))</pre> | `[]` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | n/a | `any` | n/a | yes |
| <a name="input_custom_nsg_rules"></a> [custom\_nsg\_rules](#input\_custom\_nsg\_rules) | A map of custom NSG rules to apply in addition to the default rules | <pre>map(object({<br/>    priority                     = number<br/>    direction                    = string<br/>    access                       = string<br/>    protocol                     = string<br/>    source_port_range            = optional(string)<br/>    source_port_ranges           = optional(list(string))<br/>    destination_port_range       = optional(string)<br/>    destination_port_ranges      = optional(list(string))<br/>    source_address_prefix        = optional(string)<br/>    source_address_prefixes      = optional(list(string))<br/>    destination_address_prefix   = optional(string)<br/>    destination_address_prefixes = optional(list(string))<br/>    description                  = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_department"></a> [department](#input\_department) | n/a | `any` | n/a | yes |
| <a name="input_disable_trusted_service_connectivity"></a> [disable\_trusted\_service\_connectivity](#input\_disable\_trusted\_service\_connectivity) | Disable Trusted Service Connectivity (Managed Identity over-privileged access) for APIM. Set to true to disable this feature. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"uksouth"` | no |
| <a name="input_notification_sender_email"></a> [notification\_sender\_email](#input\_notification\_sender\_email) | n/a | `string` | `"apimgmt-noreply@mail.windowsazure.com"` | no |
| <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email) | n/a | `string` | `"DTSPlatformOperations@justice.gov.uk"` | no |
| <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name) | n/a | `string` | `"HMCTS Platform Operations"` | no |
| <a name="input_route_address_prefix"></a> [route\_address\_prefix](#input\_route\_address\_prefix) | n/a | `string` | `"0.0.0.0/0"` | no |
| <a name="input_route_name"></a> [route\_name](#input\_route\_name) | n/a | `string` | `"default"` | no |
| <a name="input_route_next_hop_in_ip_address"></a> [route\_next\_hop\_in\_ip\_address](#input\_route\_next\_hop\_in\_ip\_address) | n/a | `string` | `"10.10.1.1"` | no |
| <a name="input_route_next_hop_type"></a> [route\_next\_hop\_type](#input\_route\_next\_hop\_type) | n/a | `string` | `"VirtualAppliance"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | n/a | `any` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | n/a | `any` | n/a | yes |
| <a name="input_virtual_network_resource_group"></a> [virtual\_network\_resource\_group](#input\_virtual\_network\_resource\_group) | n/a | `any` | n/a | yes |
| <a name="input_virtual_network_type"></a> [virtual\_network\_type](#input\_virtual\_network\_type) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_properties_after_update"></a> [custom\_properties\_after\_update](#output\_custom\_properties\_after\_update) | Custom properties after applying the DisableOverPrivilegedAccess setting (if disable\_trusted\_service\_connectivity is true) |
| <a name="output_existing_custom_properties"></a> [existing\_custom\_properties](#output\_existing\_custom\_properties) | Existing custom properties before applying the DisableOverPrivilegedAccess setting |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END_TF_DOCS -->