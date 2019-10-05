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
