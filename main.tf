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

# --- CDN resources commented out due to subscription restrictions ---
resource "azurerm_cdn_profile" "cdn" {
  name                = "cdnprofile-${random_id.unique.hex}"
  location            = "global"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  name                = "cdnendpoint-${random_id.unique.hex}"
  profile_name        = azurerm_cdn_profile.cdn.name
  location            = "global"
  resource_group_name = azurerm_resource_group.rg.name
  is_http_allowed     = true
  is_https_allowed    = true
  origin_host_header = "staticsite88c8e1d2.z44.web.core.windows.net"
  origin_path         = ""
  origin {
    name      = "blobstaticorigin"
    host_name = "staticsite88c8e1d2.z44.web.core.windows.net"
    https_port = 443
  }
  content_types_to_compress = ["text/html", "text/css", "application/javascript"]
  is_compression_enabled    = true
}

resource "azurerm_cdn_endpoint_custom_domain" "cdn_custom_domain" {
  name            = "cdncustomdomain"
  cdn_endpoint_id = azurerm_cdn_endpoint.cdn_endpoint.id
  host_name       = "azureblob.cloudkraft.nz"
}
