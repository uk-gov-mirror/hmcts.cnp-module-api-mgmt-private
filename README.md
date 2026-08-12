# Terraform module to create Azure APIM Instance with Private Endpoint

## Network Security Group (NSG) Rule Controls

This module includes optional controls for specific Network Security Group (NSG) rules, allowing callers to disable rules that are not required by their workload or network architecture.

### Compatibility-First Opt-Out Design

This release uses a compatibility-first opt-out approach (rather than opt-in or default-secure). All three optional NSG rule flags permanently default to `true`. Existing module consumers retain full backward compatibility upon upgrade without requiring configuration changes. Callers can explicitly disable rules by setting the corresponding variables to `false`.

### Optional NSG Rules Description & Relevance

- **`enable_access_redis_service_nsg_rule`** (default: `true`)
  - **Rule**: `AccessRedisService` (Inbound TCP ports 6381–6383 from `VirtualNetwork`)
  - **Purpose & Relevance**: Allows inbound TCP traffic for internal cache communication between machines/nodes within the APIM deployment. Relevant for internal caching features that rely on Redis cache lookup between machines/nodes within the deployment.
  - **When to disable**: Can be set to `false` if internal cache communication between machines/nodes within the APIM deployment is not required.

- **`enable_sync_counter_nsg_rule`** (default: `true`)
  - **Rule**: `SyncCounter` (Inbound UDP port 4290 from `VirtualNetwork`)
  - **Purpose & Relevance**: Allows inbound UDP traffic for rate-limit counter synchronization between machines/nodes within the APIM deployment. Relevant when rate limiting policies depend on counter synchronization between machines/nodes in the deployment.
  - **When to disable**: Can be set to `false` if rate-limit counter synchronization between machines/nodes within the APIM deployment is not required.

- **`enable_loadbalancer_nsg_rule`** (default: `true`)
  - **Rule**: `loadbalancer` (Inbound TCP port range `*` from `VirtualNetwork`)
  - **Purpose & Relevance**: Allows inbound TCP traffic originating from the `VirtualNetwork` source tag. Relevance depends on the APIM SKU and virtual network integration topology (such as internal/external VNet mode or internal load balancing).
  - **When to disable**: Can be set to `false` if network architecture and routing policies do not require this broad inbound rule from the `VirtualNetwork` tag.

### Azure Guidance & Rationale

Azure-specific rationale is grounded in official Microsoft documentation: [Azure API Management VNet Reference](https://learn.microsoft.com/azure/api-management/virtual-network-reference#required-ports).

- Official guidance classifies TCP 6381–6383 (internal cache) and UDP 4290 (counter sync) as feature-specific traffic required for internal cache communication or rate-limit counter synchronization between machines/nodes within the APIM deployment.
- Azure load balancer traffic requirements depend on the APIM SKU and VNet integration topology.
- Note: The module's existing `loadbalancer` NSG rule matches inbound TCP traffic from the `VirtualNetwork` source tag to destination port range `*`, which is broader than Microsoft's narrower health-probe guidance targeting the `AzureLoadBalancer` service tag.

### Example: Disabling Optional NSG Rules

To opt out of all three optional NSG rules when their traffic is not required:

```hcl
module "api_management" {
  source = "git::https://github.com/hmcts/cnp-module-api-mgmt-private.git?ref=vX.X.X"

  # ... required variables ...

  # Opt-out of optional NSG rules
  enable_access_redis_service_nsg_rule = false
  enable_sync_counter_nsg_rule         = false
  enable_loadbalancer_nsg_rule         = false
}
```

### Migration Guidance

- **Default Behavior**: Existing consumers upgrading to this version retain current behavior by default (`default = true`) with zero breaking changes.
- **Opting Out**: Consumers should evaluate their APIM feature usage and network topology, and set flags to `false` only after confirming that their workload does not require the corresponding traffic.
- **Resource Identity Preservation**: Module `moved` blocks change Terraform addresses to indexed `[0]` while preserving existing resource and state identity and avoiding recreation for rules left enabled (`true`).
- **Rule Removal**: Setting a flag to `false` intentionally removes/destroys the corresponding `azurerm_network_security_rule` resource from the NSG and Terraform state.

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
| [azurerm_user_assigned_identity.uami](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_routes_apim"></a> [additional\_routes\_apim](#input\_additional\_routes\_apim) | A list of additional route configurations | <pre>list(object({<br/>    name                   = string<br/>    address_prefix         = string<br/>    next_hop_type          = string<br/>    next_hop_in_ip_address = string<br/>  }))</pre> | `[]` | no |
| <a name="input_app_insights_custom_name"></a> [app\_insights\_custom\_name](#input\_app\_insights\_custom\_name) | Overrides the derived Application Insights name prefix (department-api-mgmt). The environment suffix is still appended automatically. Defaults to null (the derived name). Use when a distinct name is needed to avoid clashing with other Application Insights resources. | `string` | `null` | no |
| <a name="input_cert_domain"></a> [cert\_domain](#input\_cert\_domain) | n/a | `string` | `"platform"` | no |
| <a name="input_certificate_secret_id"></a> [certificate\_secret\_id](#input\_certificate\_secret\_id) | Versionless Key Vault secret ID of the gateway certificate. When set, it is used directly as the custom domain key\_vault\_id and the department-derived vault/certificate lookup is skipped. The certificate is fetched at runtime via the UAMI, which must have Key Vault Secrets User on the source vault. | `string` | `null` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | n/a | `any` | n/a | yes |
| <a name="input_custom_gateway_hostnames"></a> [custom\_gateway\_hostnames](#input\_custom\_gateway\_hostnames) | List of custom gateway hostnames. If not provided, defaults to the standard department-based naming. | <pre>list(object({<br/>    host_name                    = string<br/>    negotiate_client_certificate = optional(bool, true)<br/>    default_ssl_binding          = optional(bool, true)<br/>  }))</pre> | `null` | no |
| <a name="input_custom_name"></a> [custom\_name](#input\_custom\_name) | Overrides the derived instance name (department-api-mgmt-environment) used for the APIM service, public IP, NSG, route table and logger. Defaults to null (the derived name). Use when a distinct name is needed — e.g. a second APIM in a department that already owns the derived name. Does not affect department-driven vault/subscription/prefix selection. | `string` | `null` | no |
| <a name="input_custom_nsg_rules"></a> [custom\_nsg\_rules](#input\_custom\_nsg\_rules) | A map of custom NSG rules to apply in addition to the default rules | <pre>map(object({<br/>    priority                     = number<br/>    direction                    = string<br/>    access                       = string<br/>    protocol                     = string<br/>    source_port_range            = optional(string)<br/>    source_port_ranges           = optional(list(string))<br/>    destination_port_range       = optional(string)<br/>    destination_port_ranges      = optional(list(string))<br/>    source_address_prefix        = optional(string)<br/>    source_address_prefixes      = optional(list(string))<br/>    destination_address_prefix   = optional(string)<br/>    destination_address_prefixes = optional(list(string))<br/>    description                  = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_department"></a> [department](#input\_department) | n/a | `any` | n/a | yes |
| <a name="input_disable_trusted_service_connectivity"></a> [disable\_trusted\_service\_connectivity](#input\_disable\_trusted\_service\_connectivity) | Disable Trusted Service Connectivity (Managed Identity over-privileged access) for APIM. Set to true to disable this feature. | `bool` | `false` | no |
| <a name="input_enable_access_redis_service_nsg_rule"></a> [enable\_access\_redis\_service\_nsg\_rule](#input\_enable\_access\_redis\_service\_nsg\_rule) | Controls creation of the AccessRedisService NSG rule (inbound TCP 6381-6383 for internal cache communication between machines/nodes within the APIM deployment). | `bool` | `true` | no |
| <a name="input_enable_loadbalancer_nsg_rule"></a> [enable\_loadbalancer\_nsg\_rule](#input\_enable\_loadbalancer\_nsg\_rule) | Controls creation of the loadbalancer NSG rule (inbound TCP from VirtualNetwork). | `bool` | `true` | no |
| <a name="input_enable_sync_counter_nsg_rule"></a> [enable\_sync\_counter\_nsg\_rule](#input\_enable\_sync\_counter\_nsg\_rule) | Controls creation of the SyncCounter NSG rule (inbound UDP 4290 for rate-limit counter synchronization between machines/nodes within the APIM deployment). | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"uksouth"` | no |
| <a name="input_notification_sender_email"></a> [notification\_sender\_email](#input\_notification\_sender\_email) | n/a | `string` | `"apimgmt-noreply@mail.windowsazure.com"` | no |
| <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email) | n/a | `string` | `"DTSPlatformOperations@justice.gov.uk"` | no |
| <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name) | n/a | `string` | `"HMCTS Platform Operations"` | no |
| <a name="input_route_address_prefix"></a> [route\_address\_prefix](#input\_route\_address\_prefix) | n/a | `string` | `"0.0.0.0/0"` | no |
| <a name="input_route_name"></a> [route\_name](#input\_route\_name) | n/a | `string` | `"default"` | no |
| <a name="input_route_next_hop_in_ip_address"></a> [route\_next\_hop\_in\_ip\_address](#input\_route\_next\_hop\_in\_ip\_address) | n/a | `string` | `"10.10.1.1"` | no |
| <a name="input_route_next_hop_type"></a> [route\_next\_hop\_type](#input\_route\_next\_hop\_type) | n/a | `string` | `"VirtualAppliance"` | no |
| <a name="input_sampling_percentage"></a> [sampling\_percentage](#input\_sampling\_percentage) | The sampling percentage for Application Insights. Defaults to null (uses the module default). | `number` | `null` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | n/a | `any` | n/a | yes |
| <a name="input_user_assigned_managed_identity_name"></a> [user\_assigned\_managed\_identity\_name](#input\_user\_assigned\_managed\_identity\_name) | The name of a User Assigned Managed Identity to assign to the API Management Service. If not provided, only SystemAssigned identity is used. | `string` | `null` | no |
| <a name="input_user_assigned_managed_identity_resource_group"></a> [user\_assigned\_managed\_identity\_resource\_group](#input\_user\_assigned\_managed\_identity\_resource\_group) | The resource group of the User Assigned Managed Identity. Required when user\_assigned\_managed\_identity\_name is set. | `string` | `null` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | n/a | `any` | n/a | yes |
| <a name="input_virtual_network_resource_group"></a> [virtual\_network\_resource\_group](#input\_virtual\_network\_resource\_group) | n/a | `any` | n/a | yes |
| <a name="input_virtual_network_type"></a> [virtual\_network\_type](#input\_virtual\_network\_type) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_properties_after_update"></a> [custom\_properties\_after\_update](#output\_custom\_properties\_after\_update) | Custom properties after applying the DisableOverPrivilegedAccess setting (if disable\_trusted\_service\_connectivity is true) |
| <a name="output_existing_custom_properties"></a> [existing\_custom\_properties](#output\_existing\_custom\_properties) | Existing custom properties before applying the DisableOverPrivilegedAccess setting |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END_TF_DOCS -->