provider "azurerm" {
  version = "=1.36.1"
}

variable "resource_group_name" {
    default = "tools"
}

variable "tags" {
    type = map

    default = {
        Environment = "Development"
        Automation = "Terraform"
    }
}

variable "vms" {
  default = 2
}

# ResourceGroup
resource "azurerm_resource_group" "test" {
  name     = var.resource_group_name
  location = "West Europe"
}

# Networking
resource "azurerm_virtual_network" "test" {
  name                = "vnet01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_subnet" "vms" {
  name                 = "snet01"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.1.0/24"
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "getway" {
  name                 = "snet02"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
}

# Bastion
resource "azurerm_public_ip" "test" {
  name                = "pip01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "test" {
  name                = "bastion01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.test.id
  }
  tags  = var.tags
}

# Vms
resource "azurerm_network_security_group" "test" {
  name                = "nsg00"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = var.tags
}

resource "azurerm_network_interface" "test" {
  count = var.vms
  name                            = "netinterface0${count.index}"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  network_security_group_id       = azurerm_network_security_group.test.id
  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = azurerm_subnet.vms.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "test" {
  count = var.vms
  name                  = "vm0${count.index}"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = ["${azurerm_network_interface.test[count.index].id}"]
  vm_size               = "Standard_DS1_v2"
  
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "disk0${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vm0${count.index}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = var.tags
}

# Storage
resource "azurerm_storage_account" "test" {
  name                = "tutorial02storage02"
  resource_group_name = azurerm_resource_group.test.name

  location                 =  azurerm_resource_group.test.location
  account_kind             =  "StorageV2"
  account_tier             =  "Standard"
  account_replication_type =  "LRS"
  access_tier              =  "Hot"
  tags = var.tags
}

resource "azurerm_storage_share" "test" {
  name                 = "jenkins"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 50
}

# Container Instance
resource "azurerm_container_group" "test" {
  name                = "container01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "public"
  dns_name_label      = azurerm_resource_group.test.name
  os_type             = "Linux"
  
  container {
    name   = "jenkins01"
    image  = "jenkins/jenkins:lts"
    cpu    = "3"
    memory = "4"
    
    gpu {
      count = "4"
      sku   = "V100" 
    }
    
    ports {
      port     = 8080
      protocol = "TCP"
    }
    
    ports {
      port     = 50000
      protocol = "TCP"
    }

    volume {
      name          = "jenkins"
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
