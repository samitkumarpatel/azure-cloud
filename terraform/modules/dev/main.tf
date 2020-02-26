provider "azurerm" {
    version = "=1.36.1"
}

resource "azurerm_resource_group" "main" {
  name     = "rg01"
  location = "West Europe"
}

module "snet" {
  source                    = "../module/vnet"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  vnet_name                 = "vnet01"
  vnet_address_space        = ["10.0.0.0/16"]
  subnets                   = {
    "snet01" = "10.0.0.0/24",
    "snet02" = "10.0.1.0/24",
    "snet03" = "10.0.2.0/24"
  }
}
