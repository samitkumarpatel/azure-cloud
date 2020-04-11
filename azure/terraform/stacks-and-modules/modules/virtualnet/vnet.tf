resource "azurerm_virtual_network" "main" {
    name                = var.vnet_name
    address_space       = var.vnet_address_space
    location            = var.location
    resource_group_name = var.resource_group_name

    tags    =   var.tags
}

resource "azurerm_subnet" "main" {
    count                = length(var.subnets)
    name                 = element(keys(var.subnets), count.index)
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefix       = element(values(var.subnets), count.index)
}