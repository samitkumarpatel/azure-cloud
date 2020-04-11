resource "azurerm_network_interface" "example" {
  count               = var.instance_count

  name                = "ni${count.index}vm${count.index}"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "NetworkInfor"
    subnet_id                     = var.subnetid
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "example" {
  count               = var.instance_count

  name                = "vm${count.index}"
  computer_name       = "vm${count.index}"
  resource_group_name = var.rg
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