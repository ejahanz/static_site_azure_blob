variable "nsg_name" {
  description = "Name of the Network Security Group"
  type        = string
}

variable "location" {
  description = "Azure region where the NSG will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where the NSG will be created"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Network Security Group"
  type        = map(string)
  default     = {}
}

variable "enable_https_rule" {
  description = "Enable HTTPS inbound rule"
  type        = bool
  default     = true
}

variable "enable_http_rule" {
  description = "Enable HTTP inbound rule"
  type        = bool
  default     = false
}

variable "enable_security_rules" {
  description = "Enable security rules to block common attack ports"
  type        = bool
  default     = true
}

variable "enable_azure_outbound_rule" {
  description = "Enable outbound rule for Azure services"
  type        = bool
  default     = true
}

variable "https_source_address_prefix" {
  description = "Source address prefix for HTTPS rule"
  type        = string
  default     = "*"
}

variable "http_source_address_prefix" {
  description = "Source address prefix for HTTP rule"
  type        = string
  default     = "*"
}

variable "custom_rules" {
  description = "Map of custom security rules to create"
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range         = string
    destination_port_range    = string
    source_address_prefix     = string
    destination_address_prefix = string
  }))
  default = {}
}