output "static_website_url" {
  value = azurerm_storage_account.storage.primary_web_endpoint
}

output "cdn_endpoint" {
  value = azurerm_cdn_endpoint.cdn_endpoint.host_names[0]
}

output "custom_domain_url" {
  value = "https://azureblob.cloudkraft.nz"
}