provider "azurerm" {
  version = "=1.34.0"
}

variable "resource_group_name" {
    default = "tutorial02"
}

variable "tags" {
    type = "map"

    default = {
        env = "development"
        by = "terraform"
    }
}

# ResourceGroup
resource "azurerm_resource_group" "test" {
  name     = var.resource_group_name
  location = "West Europe"
}

#vnet, SubNet
resource "azurerm_network_security_group" "test" {
  name                = "nsg01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_ddos_protection_plan" "test" {
  name                = "ddos01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.test.id
    enable = true
  }

  tags = var.tags
}

resource "azurerm_subnet" "test" {
  count = 3
  name                 = "snet0${count.index}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.${count.index}.0/24"
}

resource "azurerm_storage_account" "test" {
  name                = "tutorial01storage01"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action      = "Deny"
    ip_rules            = ["10.0.0.4"]
    virtual_network_subnet_ids = [azurerm_subnet.test[0].id]
  }

  tags = {
    environment = "staging"
  }
}