provider "azurerm" {
  version = "=1.34.0"
}

variable "location" {
    default = "West Europe"
}
variable "resource_group" {
    default = "tutorial01"
}

variable "tags" {
    type = "map"

    default = {
        env = "development"
        provision_by = "terraform"
    }
}

# rg
resource "azurerm_resource_group" "test" {
  name     = var.resource_group
  location = var.location

  tags = var.tags
}

# vnet
# snet
resource "azurerm_virtual_network" "test" {
  name                = "vnet01"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
  tags = var.tags
}

# subnet
resource "azurerm_subnet" "test0" {
  name                 = "subnet01"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "test1" {
  name                 = "subnet02"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.1.0/24"
}

# public-ip
resource "azurerm_public_ip" "test" {
  name                = "public-ip01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"

  tags = var.tags
}

# nsg
resource "azurerm_network_security_group" "test0" {
  name                = "nsg01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "22"
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "test1" {
  name                = "nsg02"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "22"
  }

  security_rule {
    name                       = "http"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "80"
  }

  tags = var.tags
}

# network interface
resource "azurerm_network_interface" "test" {
  name                = "ni01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "private-ip01"
    subnet_id                     = azurerm_subnet.test0.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}