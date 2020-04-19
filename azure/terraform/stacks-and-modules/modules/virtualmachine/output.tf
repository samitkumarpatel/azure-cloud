# Map output
output "vmips_with_name" {
  value = {
    for i in azurerm_linux_virtual_machine.example :
    i.name => i.private_ip_address
  }
}

# List output
output "vmips" {
  value = [
    for i in azurerm_linux_virtual_machine.example :
    i.private_ip_address
  ]
}
