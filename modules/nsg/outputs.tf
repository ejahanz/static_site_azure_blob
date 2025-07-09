output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.nsg.id
}

output "nsg_name" {
  description = "Name of the Network Security Group"
  value       = azurerm_network_security_group.nsg.name
}

output "nsg_location" {
  description = "Location of the Network Security Group"
  value       = azurerm_network_security_group.nsg.location
}

output "nsg_resource_group_name" {
  description = "Resource group name of the Network Security Group"
  value       = azurerm_network_security_group.nsg.resource_group_name
}

output "security_rules" {
  description = "List of security rules in the NSG"
  value       = azurerm_network_security_group.nsg.security_rule
}