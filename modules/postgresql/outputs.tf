output "id" {
  description = "PostgreSQL Flexible Server resource ID"
  value       = azurerm_postgresql_flexible_server.this.id
}

output "name" {
  description = "PostgreSQL Flexible Server name"
  value       = azurerm_postgresql_flexible_server.this.name
}

output "fqdn" {
  description = "PostgreSQL Flexible Server fully qualified domain name"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "subnet_id" {
  description = "Resource ID of the delegated PostgreSQL subnet"
  value       = azurerm_subnet.this.id
}

output "private_dns_zone_id" {
  description = "Resource ID of the PostgreSQL private DNS zone"
  value       = azurerm_private_dns_zone.this.id
}

output "database_ids" {
  description = "Resource IDs of the databases keyed by database name"
  value       = { for name, database in azurerm_postgresql_flexible_server_database.this : name => database.id }
}
