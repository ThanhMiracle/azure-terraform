output "id" {
  description = "Azure Bastion Host ID"
  value       = azurerm_bastion_host.this.id
}

output "name" {
  description = "Azure Bastion Host name"
  value       = azurerm_bastion_host.this.name
}

output "public_ip_address" {
  description = "Azure Bastion Public IP address"
  value       = azurerm_public_ip.this.ip_address
}

output "dns_name" {
  description = "Azure Bastion DNS name"
  value       = azurerm_bastion_host.this.dns_name
}