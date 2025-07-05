output "static_website_url" {
  value = azurerm_storage_account.storage.primary_web_endpoint
}

output "frontdoor_endpoint" {
  value = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint.host_name
}

output "custom_domain_url" {
  value = "https://azureblob.cloudkraft.nz"
} 