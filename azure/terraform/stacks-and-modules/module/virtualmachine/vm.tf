resource "azurerm_network_interface" "example" {
  count                           = var.instance_count
  name                            = "ni${count.index}"
  location                        = var.location
  resource_group_name             = var.resource_group

  ip_configuration {
    name                          = "testconfiguration${count.index}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "example" {
  count                           = var.instance_count
  name                            = "vm${count.index}"
  location                        = var.location
  resource_group_name             = var.resource_group
  network_interface_ids           = ["${azurerm_network_interface.example[count.index].id}"]
  vm_size                         = "Standard_DS1_v2"

  storage_image_reference {
    publisher                     = "Canonical"
    offer                         = "UbuntuServer"
    sku                           = "16.04-LTS"
    version                       = "latest"
  }
  storage_os_disk {
    name                          = "vmd${count.index}"
    caching                       = "ReadWrite"
    create_option                 = "FromImage"
    managed_disk_type             = "Standard_LRS"
  }
  os_profile {
    computer_name                 = "vm${count.index}"
    admin_username                = "labadmin"
    admin_password                = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}