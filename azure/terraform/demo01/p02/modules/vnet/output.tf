output "subnets" {
  value = tolist(azurerm_virtual_network.example.subnet)
}
