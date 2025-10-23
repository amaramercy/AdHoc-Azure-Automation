output "public_ips" {
  value = [for ip in azurerm_public_ip.vm_pip : ip.ip_address]
}


# output "web_vm_public_ip" {
#   description = "The public IP address of the Mail VM"
#   value       = azurerm_public_ip.pip.ip_address
# }
