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

variable "cert_domain" {
  default = "platform"
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

variable "custom_top_level_domain" {
  description = "Custom top level domain for APIM. If not provided, defaults to platform.hmcts.net"
  type        = string
  default     = "platform.hmcts.net"
}

variable "developer_portal" {
  description = "Configuration for the APIM developer portal custom domain and certificate"
  type = object({
    sign_in_enabled = optional(bool, false)
    sign_up = optional(object({
      enabled = bool
      terms_of_service = object({
        consent_required = bool
        show_tos         = bool
        text             = string
      })
    }))
    custom_domain = optional(object({
      fqdn         = string
      key_vault_id = string
      cert_name    = string
    }))
  })
  default = {}
}

variable "management" {
  type = object({
    fqdn         = string
    key_vault_id = string
    cert_name    = string
  })
  default = null
}

variable "apim_diagnostic_settings" {
  description = "Configuration for the APIM Application Insights diagnostic settings"
  type = object({
    sampling_percentage          = optional(number, 100)
    always_log_errors            = optional(bool, true)
    http_correlation_protocol    = optional(string, "W3C")
    verbosity                    = optional(string, "information")
    frontend_request_body_bytes  = optional(number, 0)
    frontend_response_body_bytes = optional(number, 0)
    backend_request_body_bytes   = optional(number, 0)
    backend_response_body_bytes  = optional(number, 0)
  })
  default = {}
}

variable "acme_environment" {
  description = "Allows overriding the environment used for the ACME Key Vault name. If not provided, defaults to the local.acme_environment value."
  type        = string
  default     = null
}
