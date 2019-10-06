provider "azurerm" {
    version = "=1.34.0"
}

variable "location" {
    default = "West Europe"
}

resource "azurerm_resource_group" "test" {
  name        = "tutorial-rg01"
  location    = var.location
  tags = {
      environment = "test",
  }
}
resource "azurerm_storage_account" "test" {
  name                     = "storage345xxxcccddd"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "test"
  }
}

output "primary_access_key" {
  value = azurerm_storage_account.test.primary_access_key
  depends_on = [
    azurerm_storage_account.test
  ]
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
    image  = "jenkins/jenkins:latest"
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
  
  tags = {
    environment = "testing"
  }
  depends_on = [
    azurerm_storage_account.test,
    azurerm_storage_share.test
  ]
}