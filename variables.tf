variable "location" {
  default = "uksouth"
}

variable "environment" {}

variable "virtual_network_resource_group" {}

variable "virtual_network_name" {}
variable "sku_name" {}
variable "virtual_network_type" {}
variable "department" {}
variable "common_tags" {}

variable "publisher_email" {
  default = "DTSPlatformOperations@justice.gov.uk"
}

variable "publisher_name" {
  default = "HMCTS Platform Operations"
}

variable "notification_sender_email" {
  default = "apimgmt-noreply@mail.windowsazure.com"
}

variable "route_name" {
  default = "default"
}
variable "route_address_prefix" {
  default = "0.0.0.0/0"
}
variable "route_next_hop_type" {
  default = "VirtualAppliance"
}

variable "route_next_hop_in_ip_address" {
  default = "10.10.1.1"
}

variable "additional_routes_apim" {
  description = "A list of additional route configurations"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = string
  }))
  default = []
}

variable "disable_trusted_service_connectivity" {
  description = "Disable Trusted Service Connectivity (Managed Identity over-privileged access) for APIM. Set to true to disable this feature."
  type        = bool
  default     = false
}

variable "user_assigned_managed_identity_name" {
  description = "The name of a User Assigned Managed Identity to assign to the API Management Service. If not provided, only SystemAssigned identity is used."
  type        = string
  default     = null
}

variable "user_assigned_managed_identity_resource_group" {
  description = "The resource group of the User Assigned Managed Identity. Required when user_assigned_managed_identity_name is set."
  type        = string
  default     = null
}

variable "cert_domain" {
  default = "platform"
}

variable "certificate_secret_id" {
  description = "Versionless Key Vault secret ID of the gateway certificate. When set, it is used directly as the custom domain key_vault_id and the department-derived vault/certificate lookup is skipped. The certificate is fetched at runtime via the UAMI, which must have Key Vault Secrets User on the source vault."
  type        = string
  default     = null
}

variable "custom_name" {
  description = "Overrides the derived instance name (department-api-mgmt-environment) used for the APIM service, public IP, NSG, route table and logger. Defaults to null (the derived name). Use when a distinct name is needed — e.g. a second APIM in a department that already owns the derived name. Does not affect department-driven vault/subscription/prefix selection."
  type        = string
  default     = null
}

variable "custom_gateway_hostnames" {
  description = "List of custom gateway hostnames. If not provided, defaults to the standard department-based naming."
  type = list(object({
    host_name                    = string
    negotiate_client_certificate = optional(bool, true)
    default_ssl_binding          = optional(bool, true)
  }))
  default = null
}

variable "custom_nsg_rules" {
  description = "A map of custom NSG rules to apply in addition to the default rules"
  type = map(object({
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
    description                  = optional(string)
  }))
  default = {}
}
