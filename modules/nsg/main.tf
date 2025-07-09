# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Allow HTTPS inbound traffic
resource "azurerm_network_security_rule" "allow_https_inbound" {
  count                       = var.enable_https_rule ? 1 : 0
  name                        = "AllowHttpsInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = var.https_source_address_prefix
  destination_address_prefix = "*"
  resource_group_name        = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Allow HTTP inbound traffic (optional)
resource "azurerm_network_security_rule" "allow_http_inbound" {
  count                       = var.enable_http_rule ? 1 : 0
  name                        = "AllowHttpInbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "80"
  source_address_prefix      = var.http_source_address_prefix
  destination_address_prefix = "*"
  resource_group_name        = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Block common attack ports
resource "azurerm_network_security_rule" "deny_common_attack_ports" {
  count                       = var.enable_security_rules ? 1 : 0
  name                        = "DenyCommonAttackPorts"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range          = "*"
  destination_port_ranges    = ["22", "23", "135", "445", "1433", "3389", "5432", "5985", "5986"]
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name        = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Allow outbound traffic for Azure services
resource "azurerm_network_security_rule" "allow_azure_outbound" {
  count                       = var.enable_azure_outbound_rule ? 1 : 0
  name                        = "AllowAzureOutbound"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "AzureCloud"
  resource_group_name        = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Custom security rules (if provided)
resource "azurerm_network_security_rule" "custom_rules" {
  for_each = var.custom_rules

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range          = each.value.source_port_range
  destination_port_range     = each.value.destination_port_range
  source_address_prefix      = each.value.source_address_prefix
  destination_address_prefix = each.value.destination_address_prefix
  resource_group_name        = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}