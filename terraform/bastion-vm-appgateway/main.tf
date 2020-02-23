provider "azurerm" {
    version = "=1.36.1"
}

variable "resourcegroup" {
  default = "tutorial01"
}

variable "location" {
  default = "West Europe"
}

variable "nos_of_vms" {
  default = 2
}

resource "azurerm_resource_group" "example" {
  name     = var.resourcegroup
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}


#### subnet
# App Gateway snet
resource "azurerm_subnet" "agsnet" {
  name                 = "snet02"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.0.0/24"
}

# vm snet
resource "azurerm_subnet" "vmsnet" {
  name                 = "snet01"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.1.0/24"
}

# Bastion snet
resource "azurerm_subnet" "bastionsnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.2.0/24"
}



### Public IP
#Bastion pip
resource "azurerm_public_ip" "bastionpip" {
  name                = "pip01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#AppGateway pip
resource "azurerm_public_ip" "agpip" {
  name                = "pip02"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}



# Azure Bastion
resource "azurerm_bastion_host" "example" {
  name                = "bastion01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastionsnet.id
    public_ip_address_id = azurerm_public_ip.bastionpip.id
  }
}


# Network Interface
resource "azurerm_network_interface" "example" {
  count = var.nos_of_vms
  name                = "ni${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testconfiguration${count.index}"
    subnet_id                     = azurerm_subnet.vmsnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


# Virtual Machine
resource "azurerm_virtual_machine" "example" {
  count = var.nos_of_vms
  name                  = "vm${count.index}"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = ["${azurerm_network_interface.example[count.index].id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "vm${count.index}disk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vm${count.index}"
    admin_username = "labadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}



# Application Gateway
variable "appgateway" {
  default = "nginx"
}

locals {
  backend_address_pool_name      = "${var.appgateway}-backendpool"
  frontend_port_name             = "${var.appgateway}-fe80"
  frontend_ip_configuration_name = "fepip"
  http_setting_name              = "${var.appgateway}-behttp80"
  listener_name                  = "${var.appgateway}-listener"
  request_routing_rule_name      = "${var.appgateway}-rule"
  redirect_configuration_name    = "${var.appgateway}-redirect"
}

resource "azurerm_application_gateway" "example" {
  name                = "ag01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku {
    name     = "Standard_V2"
    tier     = "Standard_v2"
    capacity = 2
  }

  #application gateway subnet
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.agsnet.id
  }
  
  #application gateway public ip
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.agpip.id
  }

  #application gateway exposed port
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  #backend address pool
  backend_address_pool {
    name            = local.backend_address_pool_name
    ip_addresses    = ["10.0.1.5"]
  }

  #backend http exposed port
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  #application gateway listner
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }
  
  #application gateway rule
  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

}
