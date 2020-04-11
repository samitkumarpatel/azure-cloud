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

resource "azurerm_storage_account" "test" {
  name                     = "jenkinsstorage0001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = azurerm_resource_group.example.tags
}

resource "azurerm_storage_share" "test" {
  name                 = "jenkins01"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 50
}

# mount a storage in the vm
#sudo mount -t cifs //jenkinsstorage0001.file.core.windows.net/jenkins01 /mnt/MyAzureFileShare -o vers=3.0,username=jenkinsstorage0001,password=CKwhdG1MXQbmCxEs+0pU7ycc6ikzoeeqQLmmaTmR5ldL8XmMZ0iomfFfZzXXj+EpTvfKHdp8Zc0KzpRDoGGmQg==,dir_mode=0777,file_mode=0777,serverino