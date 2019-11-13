provider "azurerm" {
    version = "=1.36.1"
}

resource "azurerm_resource_group" "example" {
  name     = "rg01"
  location = "West Europe"
}

variable "cidr" {
  default   = "192.168.1.0/24"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet01"
  address_space       = ["192.168.1.0/24"]
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
}

resource "azurerm_subnet" "example" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = "${azurerm_resource_group.example.name}"
  virtual_network_name = "${azurerm_virtual_network.example.name}"
  address_prefix       = "192.168.1.224/27"
}

resource "azurerm_public_ip" "example" {
  name                = "pip01"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "example" {
  name                = "bastion01"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = "${azurerm_subnet.example.id}"
    public_ip_address_id = "${azurerm_public_ip.example.id}"
  }
}

#vm

resource "azurerm_subnet" "example1" {
  name                 = "snet01"
  resource_group_name  = "${azurerm_resource_group.example.name}"
  virtual_network_name = "${azurerm_virtual_network.example.name}"
  address_prefix       = "192.168.1.0/28"
}

resource "azurerm_network_interface" "example" {
  name                = "ni01"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.example1.id}"
    private_ip_address_allocation = "Dynamic"
  }
  
}

resource "azurerm_virtual_machine" "example" {
  name                  = "vm01"
  location              = "${azurerm_resource_group.example.location}"
  resource_group_name   = "${azurerm_resource_group.example.name}"
  network_interface_ids = ["${azurerm_network_interface.example.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "vm01disk01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vm01"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}