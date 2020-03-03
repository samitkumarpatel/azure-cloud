
provider "azurerm" {
  version = "=2.0.0"
  features {}
}

variable "tags" {
  type = map
  default = {
    environment = "demo"
  }
}

#rg
resource "azurerm_resource_group" "example" {
  name     = "demo01"
  location = "West Europe"

  tags = var.tags
}

variable "subnets_list" {
  type  = list
  default = [
    {
      name  = "AzureBastionSubnet",
      address = "10.0.1.0/24"
    },
    {
      name  = "snet01",
      address = "10.0.2.0/24"
    }
  ]
}


#vnet
resource "azurerm_virtual_network" "example" {
  name                = "vnet02"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
  
  dynamic "subnet" {
    for_each = [for s in var.subnets_list: {
      name   = s.name
      prefix = s.address
    }]

    content {
      name           = subnet.value.name
      address_prefix = subnet.value.prefix
    }
  }

  tags = var.tags
}


#bastion
resource "azurerm_public_ip" "example" {
  name                = "pip01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "example" {
  name                = "bastion01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                 = "BastionConfig"
    subnet_id            = element(tolist(azurerm_virtual_network.example.subnet),0).id
    public_ip_address_id = azurerm_public_ip.example.id
  }
  tags = var.tags
}

#vm
resource "azurerm_network_interface" "example" {
  name                = "ni01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "NetworkInfor"
    subnet_id                     = element(tolist(azurerm_virtual_network.example.subnet),1).id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "vm01"
  computer_name       = "vm01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "Password123!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  tags = var.tags
}

output "vm_private_ip" {
  value = azurerm_linux_virtual_machine.example.private_ip_address
}