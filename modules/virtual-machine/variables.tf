variable "name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet where the VM NIC will be created"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "VM administrator username"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "VM administrator password"
  type        = string
  sensitive   = true
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage type"
  type        = string
  default     = "Standard_LRS"
}

variable "public_ip_enabled" {
  description = "Create and attach a public IP"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Azure resource tags"
  type        = map(string)
  default     = {}
}
