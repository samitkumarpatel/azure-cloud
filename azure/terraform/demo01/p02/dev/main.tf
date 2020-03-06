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
  name                =   "vnet01"
  tags                =   var.tags
}

module "bastion" {
  source              =   "../modules/bastion"
  rg                  =   azurerm_resource_group.example.name
  location            =   azurerm_resource_group.example.location
  name                =   "bastion01"
  subnetid            =   element(module.vnet.subnets,0).id
  tags                =   var.tags
}

module "vm" {
  source              =   "../modules/vm"
  rg                  =   azurerm_resource_group.example.name
  location            =   azurerm_resource_group.example.location
  subnetid            =   element(module.vnet.subnets,1).id
  tags                =   var.tags
}

module "appgateway" {
  source              =   "../modules/appgateway"
  rg                  =   azurerm_resource_group.example.name
  location            =   azurerm_resource_group.example.location
  subnetid            =   element(module.vnet.subnets,2).id
  vmips               =   module.vm.vmips
  tags                =   var.tags
}