resource "azurerm_network_security_group" "apim" {
  name                = "${local.name}-nsg"
  location            = var.location
  resource_group_name = var.virtual_network_resource_group
  tags                = var.common_tags
}

resource "azurerm_subnet_network_security_group_association" "apim" {
  subnet_id                 = data.azurerm_subnet.api-mgmt-subnet.id
  network_security_group_id = azurerm_network_security_group.apim.id
}

resource "azurerm_network_security_rule" "palo" {
  name                        = "palo"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefixes     = split(",", local.palo_ip_addresses[[for x in keys(local.palo_environment_mapping) : x if contains(local.palo_environment_mapping[x], local.environment)][0]].addresses)
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.virtual_network_resource_group
  network_security_group_name = azurerm_network_security_group.apim.name
}

resource "azurerm_network_security_rule" "apimanagement" {
  name                        = "apimanagement"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3443"
  source_address_prefix       = "ApiManagement"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.virtual_network_resource_group
  network_security_group_name = azurerm_network_security_group.apim.name
}

resource "azurerm_network_security_rule" "vpn" {
  name                        = "vpn"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = [80, 443]
  source_address_prefix       = "10.99.0.0/18"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.virtual_network_resource_group
  network_security_group_name = azurerm_network_security_group.apim.name
}

resource "azurerm_network_security_rule" "AccessRedisService" {
  count = var.enable_access_redis_service_nsg_rule ? 1 : 0

  name                        = "AccessRedisService"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = [6381, 6382, 6383]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.virtual_network_resource_group
  network_security_group_name = azurerm_network_security_group.apim.name
}

resource "azurerm_network_security_rule" "SyncCounter" {
  count = var.enable_sync_counter_nsg_rule ? 1 : 0

  name                        = "SyncCounter"
  priority                    = 104
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_ranges     = ["4290"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.virtual_network_resource_group
  network_security_group_name = azurerm_network_security_group.apim.name
}

resource "azurerm_network_security_rule" "loadbalancer" {
  count = var.enable_loadbalancer_nsg_rule ? 1 : 0

  name                        = "loadbalancer"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.virtual_network_resource_group
  network_security_group_name = azurerm_network_security_group.apim.name
}

resource "azurerm_network_security_rule" "deny" {
  name                        = "deny"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.virtual_network_resource_group
  network_security_group_name = azurerm_network_security_group.apim.name
}

resource "azurerm_network_security_rule" "custom" {
  for_each = var.custom_nsg_rules

  name                         = each.key
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range
  source_port_ranges           = each.value.source_port_ranges
  destination_port_range       = each.value.destination_port_range
  destination_port_ranges      = each.value.destination_port_ranges
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
  description                  = each.value.description
  resource_group_name          = var.virtual_network_resource_group
  network_security_group_name  = azurerm_network_security_group.apim.name
}
