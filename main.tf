provider "azurerm" {
  features {}
  subscription_id = "467adf56-8638-481d-bbca-8e430ba2bbc6"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-static-website"
  location = "New Zealand North"
}

resource "azurerm_storage_account" "storage" {
  name                     = "staticsite${random_id.unique.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_static_website" "website" {
  storage_account_id = azurerm_storage_account.storage.id
  index_document     = "index.html"
  error_404_document = "error.html"
}

resource "random_id" "unique" {
  byte_length = 4
}

# azurerm_storage_static_website.storage

# Create CDN Profile

resource "azurerm_cdn_profile" "cdn" {
  name                = "cdnprofile-${random_id.unique.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard_Microsoft"
}

# CDN Endpoint pointing to the static website

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  name                = "cdnendpoint-${random_id.unique.hex}"
  profile_name        = azurerm_cdn_profile.cdn.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  is_http_allowed     = false
  is_https_allowed    = true
  origin_host_header  = azurerm_storage_account_static_website.website.primary_web_endpoint
  origin_path         = ""
  origin {
    name      = "blobstaticorigin"
    host_name = azurerm_storage_account_static_website.website.primary_web_endpoint
    https_port = 443
  }
  content_types_to_compress = ["text/html", "text/css", "application/javascript"]
  is_compression_enabled    = true
}

# Map Custom Domain to CDN

resource "azurerm_cdn_endpoint_custom_domain" "cdn_custom_domain" {
  name            = "cdncustomdomain"
  cdn_endpoint_id = azurerm_cdn_endpoint.cdn_endpoint.id
  host_name       = "https://azureblob.cloudkraft.nz"
}
