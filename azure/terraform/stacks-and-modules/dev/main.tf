provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "main" {
  name      =   "rg01"
  location  =   "West Europe"
  tags                =   {
      environment = "dev" 
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
    "VMSubnet"              = "10.0.1.0/24",
    "AppGatewaySubnet"      = "10.0.2.0/28"
  }
  tags                      = azurerm_resource_group.main.tags
}

#Bastion
module "bastion" {
  source                =   "../modules/bastion"
  resource_group_name   =   azurerm_resource_group.main.name
  location              =   azurerm_resource_group.main.location
  #name                 =   "bastion01"
  #public_ip_name       =   "bastionpip01" 
  subnet_id             =   element(module.virtualnet.subnetsIds,0)
  tags                  =   azurerm_resource_group.main.tags
}

#vm
module "vm" {
  source                =   "../modules/virtualmachine"
  resource_group_name   =   azurerm_resource_group.main.name
  location              =   azurerm_resource_group.main.location
  instance_count        =   2
  #name                 =   "dev"
  subnet_id             =   element(module.virtualnet.subnetsIds,1)
  tags                  =   azurerm_resource_group.main.tags
}

#Application Gateway

module "appgateway" {
  source                        =   "../modules/appgateway"
  resource_group_name           =   azurerm_resource_group.main.name
  location                      =   azurerm_resource_group.main.location
  subnet_id                     =   element(module.virtualnet.subnetsIds,2)
  gateway_config                =   [
    {
      gwFrontendHttpPortName    = "NginxFe80"
      gwBackendPoolName         = "NginxBePool"
      gwBackendPoolIps          = module.vm.vmips
      gwBackendHttpPortName     = "NginxBeHttp80"
      port                      = 80
      gatewayListnerName        = "NginxListner"
      gatewayRuleName           = "NginxRule"
      probe                     =  { name: "awx", path:"/" }
      cookie                    =  "Enabled"
    },
    {
      gwFrontendHttpPortName    = "JenkinsFe8080"
      gwBackendPoolName         = "JenkinsBePool"
      gwBackendPoolIps          = module.vm.vmips
      gwBackendHttpPortName     = "JenkinsBeHttp8080"
      port                      = 8080
      gatewayListnerName        = "JenkinsListner"
      gatewayRuleName           = "JenkinsRule"
      probe                     =  { name: "awx", path:"/" }
      cookie                    =  "Enabled"
    }
  ]
  tags      =   azurerm_resource_group.main.tags
}
