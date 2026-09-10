output "vm_id" {
  description = "Virtual machine resource ID"
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "Virtual machine name"
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "Private IP address"
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address"
  value       = var.public_ip_enabled ? azurerm_public_ip.this[0].ip_address : null
}

output "principal_id" {
  description = "Managed Identity principal ID"
  value       = azurerm_linux_virtual_machine.this.identity[0].principal_id
}

output "docker_extension_id" {
  description = "ID of the Custom Script Extension that installs Docker"
  value       = azurerm_virtual_machine_extension.docker.id
}
