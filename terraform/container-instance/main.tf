provider "azurerm" {
    version = "=1.34.0"
}

variable "resource_group_name" {
  default = "tutorial01"
}

variable "location" {
    default = "West Europe"
}

variable "storagename" {
    default = "tutorial01poc01"
}

variable "tags" {
    type = "map"

    default = {
        env = "development"
    }
}

resource "azurerm_resource_group" "test" {
  name        = var.resource_group_name
  location    = var.location
  tags = var.tags
}

resource "azurerm_storage_account" "test" {
  name                     = var.storagename
  resource_group_name      = azurerm_resource_group.test.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = var.tags
}

resource "azurerm_storage_share" "test" {
  name                 = "jenkins01"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 50
}

resource "azurerm_container_group" "test" {
  name                = "container01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "public"
  dns_name_label      = "tutorial01"
  os_type             = "Linux"
  
  container {
    name   = "jenkins01"
    image  = "jenkins/jenkins:lts"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }
    ports {
      port     = 50000
      protocol = "TCP"
    }

    volume {
      name          = "jenkins01"
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