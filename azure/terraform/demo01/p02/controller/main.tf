provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "example" {
  name                =   "controller01"
  location            =   "West Europe"
  tags                =   {
      environment = "controller" 
  }
}

module "vnet" {
  source              =   "../modules/vnet"
  rg                  =   azurerm_resource_group.example.name
  location            =   azurerm_resource_group.example.location
  name                =   "vnet01"
  vnet_address_space  =   ["10.0.0.0/16"]
  subnets_list        =   [
    {
        name  = "AzureBastionSubnet",
        address = "10.0.1.0/24"
    },
    {
        name  = "VmSubnet",
        address = "10.0.2.0/24"
    }
  ]
  tags                =   azurerm_resource_group.example.tags
}

module "bastion" {
  source              =   "../modules/bastion"
  rg                  =   azurerm_resource_group.example.name
  location            =   azurerm_resource_group.example.location
  name                =   "bastion01"
  subnetid            =   element(module.vnet.subnets,0).id
  tags                =   azurerm_resource_group.example.tags
}

module "vm" {
  source              =   "../modules/vm"
  rg                  =   azurerm_resource_group.example.name
  location            =   azurerm_resource_group.example.location
  subnetid            =   element(module.vnet.subnets,1).id
  tags                =   azurerm_resource_group.example.tags
}