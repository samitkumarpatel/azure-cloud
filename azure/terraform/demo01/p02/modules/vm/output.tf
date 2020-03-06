output "vm_private_ip" {
  value = {
    for i in azurerm_linux_virtual_machine.example :
    i.name => i.private_ip_address
  }
}

output "vmips" {
  value = [
    for i in azurerm_linux_virtual_machine.example :
    i.private_ip_address
  ]
}
