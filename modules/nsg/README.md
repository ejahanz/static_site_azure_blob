# Network Security Group (NSG) Module

This Terraform module creates an Azure Network Security Group (NSG) with configurable security rules to control network traffic.

## Features

- Creates an Azure Network Security Group
- Configurable HTTPS and HTTP inbound rules
- Built-in security rules to block common attack ports
- Azure service outbound connectivity
- Support for custom security rules
- Comprehensive tagging support

## Usage

```hcl
module "nsg" {
  source = "./modules/nsg"

  nsg_name            = "my-nsg"
  location            = "East US"
  resource_group_name = "my-resource-group"
  
  # Optional: Configure security rules
  enable_https_rule         = true
  enable_http_rule         = false
  enable_security_rules    = true
  enable_azure_outbound_rule = true
  
  # Optional: Custom rules
  custom_rules = {
    ssh_rule = {
      name                       = "AllowSSH"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range         = "*"
      destination_port_range    = "22"
      source_address_prefix     = "10.0.0.0/8"
      destination_address_prefix = "*"
    }
  }
  
  # Optional: Tags
  tags = {
    Environment = "production"
    Project     = "static-website"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nsg_name | Name of the Network Security Group | `string` | n/a | yes |
| location | Azure region where the NSG will be created | `string` | n/a | yes |
| resource_group_name | Name of the resource group where the NSG will be created | `string` | n/a | yes |
| tags | Tags to apply to the Network Security Group | `map(string)` | `{}` | no |
| enable_https_rule | Enable HTTPS inbound rule | `bool` | `true` | no |
| enable_http_rule | Enable HTTP inbound rule | `bool` | `false` | no |
| enable_security_rules | Enable security rules to block common attack ports | `bool` | `true` | no |
| enable_azure_outbound_rule | Enable outbound rule for Azure services | `bool` | `true` | no |
| https_source_address_prefix | Source address prefix for HTTPS rule | `string` | `"*"` | no |
| http_source_address_prefix | Source address prefix for HTTP rule | `string` | `"*"` | no |
| custom_rules | Map of custom security rules to create | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| nsg_id | ID of the Network Security Group |
| nsg_name | Name of the Network Security Group |
| nsg_location | Location of the Network Security Group |
| nsg_resource_group_name | Resource group name of the Network Security Group |
| security_rules | List of security rules in the NSG |

## Security Rules

### Default Rules

When enabled, the module creates the following default security rules:

1. **HTTPS Inbound** (Priority 100): Allows HTTPS traffic on port 443
2. **HTTP Inbound** (Priority 110): Allows HTTP traffic on port 80 (disabled by default)
3. **Block Attack Ports** (Priority 1000): Denies traffic on common attack ports (22, 23, 135, 445, 1433, 3389, 5432, 5985, 5986)
4. **Azure Outbound** (Priority 200): Allows outbound traffic to Azure services

### Custom Rules

You can add custom security rules using the `custom_rules` variable. Each rule should include:

- `name`: Name of the security rule
- `priority`: Priority (100-4096, lower numbers have higher priority)
- `direction`: "Inbound" or "Outbound"
- `access`: "Allow" or "Deny"
- `protocol`: "Tcp", "Udp", "Icmp", or "*"
- `source_port_range`: Source port range
- `destination_port_range`: Destination port range
- `source_address_prefix`: Source address prefix
- `destination_address_prefix`: Destination address prefix

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## Example: Integration with Static Website

```hcl
module "static_site_nsg" {
  source = "./modules/nsg"

  nsg_name            = "static-site-nsg-${random_id.unique.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  # Only allow HTTPS for static site
  enable_https_rule  = true
  enable_http_rule   = false
  
  tags = {
    Environment = "production"
    Project     = "static-website"
    ManagedBy   = "terraform"
  }
}
```