resource "azurerm_public_ip" "main" {
  name                = "pip01"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "main" {
  name                = "bastion01"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.example.id
  }
}