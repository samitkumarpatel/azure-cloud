output "application_gateway_public_ip" {
  value = azurerm_public_ip.network.ip_address
}