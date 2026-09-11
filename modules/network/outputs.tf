output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "app_subnet_id" {
  value = azurerm_subnet.app.id
}

output "application_gateway_subnet_id" {
  description = "ID of the dedicated Application Gateway subnet"
  value       = azurerm_subnet.application_gateway.id
}
output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}