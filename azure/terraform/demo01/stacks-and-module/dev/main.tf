provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "example" {
  name                =   var.rg
  location            =   var.location
  tags                =   var.tags
}

module "vnet" {
  source              =   "../modules/vnet"
  rg                  =   azurerm_resource_group.example.name
  location            =   azurerm_resource_group.example.location
  name                =   "DevVnet"
  vnet_address_space  =   ["10.1.0.0/16"]
  subnets_list        =   [
    {
        name  = "VmSubnet",
        address = "10.1.1.0/24"
    },
    {
        name  = "AppGatewaySubnet",
        address = "10.1.2.0/24"
    }
  ]
  tags                =   var.tags
}

module "vm" {
  source              =   "../modules/vm"
  rg                  =   azurerm_resource_group.example.name
  location            =   azurerm_resource_group.example.location
  subnetid            =   element(module.vnet.subnets,0).id
  tags                =   var.tags
}

module "appgateway" {
  source              =   "../modules/appgateway"
  rg                  =   azurerm_resource_group.example.name
  location            =   azurerm_resource_group.example.location
  subnetid            =   element(module.vnet.subnets,1).id
  vmips               =   module.vm.vmips
  tags                =   var.tags
}