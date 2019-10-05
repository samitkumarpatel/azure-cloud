provider "azurerm" {
  version = "=1.34.0"
}

variable "location" {
  default = "West Europe"
}

resource "azurerm_resource_group" "test" {
  name     = "tutorial-rg01"
  location = var.location
  tags = {
    environment = "test",
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "storage123xxxcccddd"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "test"
  }
}

resource "azurerm_storage_share" "test" {
  name                 = "share01"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 50
}

resource "azurerm_storage_share_directory" "test" {
  name                 = "folder01"
  share_name           = azurerm_storage_share.test.name
  storage_account_name = azurerm_storage_account.test.name
}