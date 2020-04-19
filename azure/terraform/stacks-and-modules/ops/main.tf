provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "main" {
  name      =   "ops02"
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
    "AppGatewaySubnet"      = "10.0.2.0/28",
  }
  tags                      = azurerm_resource_group.main.tags
}

#Bastion
module "bastion" {
  source                =   "../modules/bastion"
  resource_group_name   =   azurerm_resource_group.main.name
  location              =   azurerm_resource_group.main.location
  name                  =   "bastion01"
  public_ip_name        =   "bastionpip01" 
  subnet_id             =   element(module.virtualnet.subnetsIds,0)
  tags                  =   azurerm_resource_group.main.tags
}

#vm
module "opsvm" {
  source                =   "../modules/virtualmachine"
  resource_group_name   =   azurerm_resource_group.main.name
  location              =   azurerm_resource_group.main.location
  name                  =   "ops"
  subnet_id             =   element(module.virtualnet.subnetsIds,1)
  tags                  =   azurerm_resource_group.main.tags
}

#vm
module "othervm" {
  source                =   "../modules/virtualmachine"
  resource_group_name   =   azurerm_resource_group.main.name
  location              =   azurerm_resource_group.main.location
  instance_count        =   2
  name                  =   "other"
  subnet_id             =   element(module.virtualnet.subnetsIds,1)
  tags                  =   azurerm_resource_group.main.tags
}

# aci
module "aci" {
  source     =  "../modules/container_instance"
  resource_group_name   =   azurerm_resource_group.main.name
  location              =   azurerm_resource_group.main.location
  vnet_name             =   module.virtualnet.name
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
      gwBackendPoolIps          = module.opsvm.vmips
      gwBackendHttpPortName     = "NginxBeHttp80"
      port                      = 80
      gatewayListnerName        = "NginxListner"
      gatewayRuleName           = "NginxRule"
      probe                     = { name: "nginx",path:"/" }
      cookie                    =  "Disabled"
    },
    {
      gwFrontendHttpPortName    =  "AWXFe8081"
      gwBackendPoolName         =  "AWXBePool"
      gwBackendPoolIps          =  module.opsvm.vmips
      gwBackendHttpPortName     =  "AWXBeHttp8081"
      port                      =  8081
      gatewayListnerName        =  "AWXListner"
      gatewayRuleName           =  "AWXRule"
      probe                     =  { name: "awx", path:"/" }
      cookie                    =  "Enabled"
    },
    {
      gwFrontendHttpPortName    = "JenkinsFe8080"
      gwBackendPoolName         = "JenkinsBePool"
      gwBackendPoolIps          = module.aci.ips
      gwBackendHttpPortName     = "JenkinsBeHttp8080"
      port                      = 8080
      gatewayListnerName        = "JenkinsListner"
      gatewayRuleName           = "JenkinsRule"
      probe                     = { name: "jenkins", path:"/login" }
      cookie                    =  "Enabled"
    },
  ]
  tags      =   azurerm_resource_group.main.tags
}