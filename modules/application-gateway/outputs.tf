output "id" {
  description = "Application Gateway ID"
  value       = azurerm_application_gateway.this.id
}

output "name" {
  description = "Application Gateway name"
  value       = azurerm_application_gateway.this.name
}

output "public_ip_address" {
  description = "Application Gateway public IP address"
  value       = azurerm_public_ip.this.ip_address
}

output "public_url" {
  description = "Application Gateway public HTTP URL"
  value       = "http://${azurerm_public_ip.this.ip_address}:${var.frontend_port}"
}
