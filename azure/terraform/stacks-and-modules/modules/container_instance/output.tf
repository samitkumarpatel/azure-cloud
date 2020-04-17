output "ips" {
  value = list(azurerm_container_group.test.ip_address)
}
