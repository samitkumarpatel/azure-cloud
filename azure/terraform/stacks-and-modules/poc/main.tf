provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "main" {
  name      =   "rg03"
  location  =   "West Europe"
  tags                =   {
      Environment = "Development"
  }
}

# vnet
module "virtualnet" {
  source                    = "../modules/virtualnet"
  vnet_name                 = "vnet01"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  vnet_address_space        = ["10.0.0.0/16"]
  subnets                   = {
    "AzureBastionSubnet"    = "10.0.0.0/28",
    "VMSubnet"              = "10.0.1.0/24"
  }
  tags                      = azurerm_resource_group.main.tags
}

#Bastion
module "bastion" {
  source                =   "../modules/bastion"
  resource_group_name   =   azurerm_resource_group.main.name
  location              =   azurerm_resource_group.main.location
  name                  =   "bastion"
  public_ip_name        =   "bastionpip"
  subnet_id             =   element(module.virtualnet.subnetsIds,0)
  tags                  =   azurerm_resource_group.main.tags
}

#vm
module "opsvm" {
  source                =   "../modules/virtualmachine"
  resource_group_name   =   azurerm_resource_group.main.name
  location              =   azurerm_resource_group.main.location
  name                  =   "poc"
  subnet_id             =   element(module.virtualnet.subnetsIds,1)
  tags                  =   azurerm_resource_group.main.tags
}
