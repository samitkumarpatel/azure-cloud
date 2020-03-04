
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
    },
    {
      name  = "snet02",
      address = "10.0.3.0/24"
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

variable "instance" {
  default = 2
}


#vm
resource "azurerm_network_interface" "example" {
  count = var.instance

  name                = "ni${count.index}"
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
  count = var.instance

  name                = "vm${count.index}"
  computer_name       = "vm${count.index}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "Password123!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example[count.index].id,
  ]

  os_disk {
    name                 = "disk${count.index}vm${count.index}"
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
  value = {
    for i in azurerm_linux_virtual_machine.example:
    i.name => i.private_ip_address
  }
}

locals {
  gateway_public_ip_name    = "nginx-gateway-pip01"
  frontend_port_name        = "nginx-fe-port80"
  frontend_ip_name          = "nginx-fe-ip01"
  backend_pool_name         = "nginx-be-pool01"
  backend_http_name         = "nginx-be-http80"
  listner_name              = "nginx-listner01"
  rule_name                 = "nginx-rule01"
}


#application gateway
resource "azurerm_public_ip" "network" {
  name                = "pip02"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Dynamic"
}

output "application_gateway_public_ip" {
  value = azurerm_public_ip.network.ip_address
}

resource "azurerm_application_gateway" "example" {
  name                = "ag01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = local.gateway_public_ip_name
    subnet_id = element(tolist(azurerm_virtual_network.example.subnet),2).id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  
  frontend_ip_configuration {
    name                 = local.frontend_ip_name
    public_ip_address_id = azurerm_public_ip.network.id
  }
  
  backend_address_pool {
    name = local.backend_pool_name
    ip_addresses = [
      for n in azurerm_linux_virtual_machine.example:
      n.private_ip_address
    ]
  }

  backend_http_settings {
    name                  = local.backend_http_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listner_name
    frontend_ip_configuration_name = local.frontend_ip_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listner_name
    backend_address_pool_name  = local.backend_pool_name
    backend_http_settings_name = local.backend_http_name
  }
}

# after this login to any VM through bastion host
# run the below command
# sudo apt update
# sudo apt install docker.io
# sudo usermod -aG docker ${USER}
# su - ${USER}
# docker swarm init
# docker service create --name nginx --publish 80:80 --replicas 1 nginx:latest
# access the application gateway public , you can see nginx home page