resource "azurerm_public_ip" "example" {
  name                = "pip01${var.name}"
  location            = var.location
  resource_group_name = var.rg
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "example" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                 = "BastionConfig"
    subnet_id            = var.subnetid
    public_ip_address_id = azurerm_public_ip.example.id
  }

  tags = var.tags
}