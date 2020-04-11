### stacks and module

stacks and module is an demonstration to build a reusable module and use it as an stack

Folder structure

```
stacks-and-module
|___modules
|___dev
|___prod

```

module folder contain several module like virtualnet, virtualmachine, bastion and appgateway with several pre-defined variable and output

dev and prod folder are called it as dev-stacks and prod-stacks

In general a stacks can be look like :

Note : All the variable hardcoded in this file can be go to vars.tf file to minimise the complexity around Read

The below stack can create virtualnet, virtualmachine based on your needs and will be secure with a bastion host (It means, you can only ssh to the vm from bastion hosts) and application gateway with one public ips to access the deployed resources.

```yml
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
  subnet_id             =   element(module.virtualnet.subnetsIds,0).id
  tags                  =   azurerm_resource_group.main.tags
}

#vm
module "vm" {
  source                =   "../modules/virtualmachine"
  resource_group_name   =   azurerm_resource_group.main.name
  location              =   azurerm_resource_group.main.location
  instance_count        =   2
  #name                 =   "dev"
  subnet_id             =   element(module.virtualnet.subnetsIds,1).id
  tags                  =   azurerm_resource_group.main.tags
}

#Application Gateway

module "appgateway" {
  source                        =   "../modules/appgateway"
  resource_group_name           =   azurerm_resource_group.main.name
  location                      =   azurerm_resource_group.main.location
  subnet_id                     =   element(module.virtualnet.subnetsIds,2).id
  gateway_config                =   [
    {
      gwFrontendHttpPortName    = "NginxFe80"
      gwBackendPoolName         = "NginxBePool"
      gwBackendPoolIps          = module.vm.vmips
      gwBackendHttpPortName     = "NginxBeHttp80"
      port                      = 80
      gatewayListnerName        = "NginxListner"
      gatewayRuleName           = "NginxRule"
    },
    {
      gwFrontendHttpPortName    = "JenkinsFe8080"
      gwBackendPoolName         = "JenkinsBePool"
      gwBackendPoolIps          = module.vm.vmips
      gwBackendHttpPortName     = "JenkinsBeHttp8080"
      port                      = 8080
      gatewayListnerName        = "JenkinsListner"
      gatewayRuleName           = "JenkinsRule"
    }
  ]
  tags      =   azurerm_resource_group.main.tags
}

```