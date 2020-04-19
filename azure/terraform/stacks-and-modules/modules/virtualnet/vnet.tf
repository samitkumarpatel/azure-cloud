resource "azurerm_virtual_network" "main" {
    name                = var.vnet_name
    address_space       = var.vnet_address_space
    location            = var.location
    resource_group_name = var.resource_group_name
    dynamic "subnet" {
      for_each  =  var.subnets
      content {
        name           = subnet.key
        address_prefix = subnet.value
      }
    }
    tags    =   var.tags
}