#vnet
resource "azurerm_virtual_network" "example" {
  name                = "vnet02"
  location            = var.location
  resource_group_name = var.rg
  address_space       = var.vnet_address_space
  
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