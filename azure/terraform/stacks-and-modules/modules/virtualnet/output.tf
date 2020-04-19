# List output
output "subnetsIds" {
  value = [
    for i in azurerm_virtual_network.main.subnet :
      i.id
  ]
}

output "vnetid" {
  value = azurerm_virtual_network.main.id
}

output "name" {
  value = azurerm_virtual_network.main.name
}
