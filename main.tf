provider "azurerm" {
  features {}
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

  static_website {
    index_document     = "index.html"
    error_404_document = "error.html"
  }
}

resource "random_id" "unique" {
  byte_length = 4
}