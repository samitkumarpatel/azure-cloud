provider "azurerm" {
    version = "=2.0.0"
    features {}
}

variable "resource_group_name" {
  default = "ci01"
}

variable "location" {
    default = "West Europe"
}

variable "storagename" {
    default = "ci01jenkinsstorag001"
}

variable "tags" {
    type = map

    default = {
        Environment = "Dev"
    }
}

resource "azurerm_resource_group" "test" {
  name        = var.resource_group_name
  location    = var.location
  tags        = var.tags
}

# vnet
resource "azurerm_virtual_network" "test" {
  name                = "vnet01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "ContainerInstance"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_profile" "test" {
  name                = "vnet01profile"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  container_network_interface {
    name = "testcnic"

    ip_configuration {
      name      = "testipconfig"
      subnet_id = azurerm_subnet.test.id
    }
  }
}


# storage

resource "azurerm_storage_account" "test" {
  name                     = var.storagename
  resource_group_name      = azurerm_resource_group.test.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

resource "azurerm_storage_share" "test" {
  name                 = "jenkins-home"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 50
}

# aci

resource "azurerm_container_group" "test" {
  name                = "contineous-integration"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "private"
  network_profile_id  = azurerm_network_profile.test.id
  os_type             = "Linux"
  
  container {
    name   = "jenkins01"
    image  = "jenkins/jenkins:lts"
    cpu    = "2"
    memory = "4"
    
    
    ports {
      port     = 8080
      protocol = "TCP"
    }
    
    ports {
      port     = 50000
      protocol = "TCP"
    }

    volume {
      name          = "jenkins-home"
      mount_path    = "/var/jenkins_home"
      storage_account_name = azurerm_storage_account.test.name
      storage_account_key = azurerm_storage_account.test.primary_access_key
      share_name = azurerm_storage_share.test.name
    }
  }
  
  tags = var.tags
  
  depends_on = [
    azurerm_storage_account.test,
    azurerm_storage_share.test
  ]
}