variable "name" {
  description = "Globally unique name of the PostgreSQL Flexible Server"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "The server name must be 3-63 lowercase letters, numbers, or hyphens, and cannot start or end with a hyphen."
  }
}

variable "resource_group_name" {
  description = "Resource group in which to create PostgreSQL resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the existing virtual network"
  type        = string
}

variable "virtual_network_id" {
  description = "Resource ID of the existing virtual network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the dedicated PostgreSQL subnet to create"
  type        = string
  default     = "snet-postgresql"
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the dedicated PostgreSQL subnet"
  type        = list(string)

  validation {
    condition     = length(var.subnet_address_prefixes) > 0
    error_message = "At least one PostgreSQL subnet address prefix is required."
  }
}

variable "private_dns_zone_name" {
  description = "Private DNS zone used by the PostgreSQL Flexible Server"
  type        = string
  default     = "private.postgres.database.azure.com"

  validation {
    condition     = endswith(var.private_dns_zone_name, ".postgres.database.azure.com")
    error_message = "The private DNS zone name must end with .postgres.database.azure.com."
  }
}

variable "administrator_login" {
  description = "PostgreSQL administrator login"
  type        = string
  default     = "pgadmin"
}

variable "administrator_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}

variable "postgresql_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
}

variable "sku_name" {
  description = "PostgreSQL Flexible Server SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Maximum storage allocated to the server in MB"
  type        = number
  default     = 32768
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention must be between 7 and 35 days."
  }
}

variable "geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = false
}

variable "zone" {
  description = "Availability zone for the primary server; null lets Azure choose"
  type        = string
  default     = null
}

variable "high_availability_mode" {
  description = "High availability mode (ZoneRedundant or SameZone); null disables HA"
  type        = string
  default     = null

  validation {
    condition     = var.high_availability_mode == null || contains(["ZoneRedundant", "SameZone"], var.high_availability_mode)
    error_message = "High availability mode must be ZoneRedundant, SameZone, or null."
  }
}

variable "standby_availability_zone" {
  description = "Availability zone for the standby server when HA is enabled"
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "Weekly maintenance window in UTC"
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }

  validation {
    condition = (
      var.maintenance_window.day_of_week >= 0 && var.maintenance_window.day_of_week <= 6 &&
      var.maintenance_window.start_hour >= 0 && var.maintenance_window.start_hour <= 23 &&
      var.maintenance_window.start_minute >= 0 && var.maintenance_window.start_minute <= 59
    )
    error_message = "Maintenance day must be 0-6, hour 0-23, and minute 0-59."
  }
}

variable "databases" {
  description = "Databases to create, keyed by database name"
  type = map(object({
    charset   = optional(string, "UTF8")
    collation = optional(string, "en_US.utf8")
  }))
  default = {}
}

variable "server_configurations" {
  description = "PostgreSQL server parameters, keyed by parameter name"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Azure resource tags"
  type        = map(string)
  default     = {}
}
