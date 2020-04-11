output "subnets" {
  value = tolist(azurerm_virtual_network.example.subnet)
}

output "id" {
  value = azurerm_virtual_network.example.id
}
