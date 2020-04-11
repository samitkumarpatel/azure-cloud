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

resource "azurerm_linux_virtual_machine" "example" {
  count               = var.instance_count

  name                = "${var.name}_vm${count.index}"
  computer_name       = "${var.name}_vm${count.index}"
  resource_group_name = var.resource_group
  location            = var.location
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