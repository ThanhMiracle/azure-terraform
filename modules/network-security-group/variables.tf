variable "name" {
  description = "Name of the network security group"
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
  description = "ID of the subnet to associate with the network security group"
  type        = string
}

variable "ssh_source_address_prefix" {
  description = "Source CIDR allowed to connect to TCP port 22"
  type        = string
  default     = "*"
}

variable "tags" {
  description = "Tags applied to the network security group"
  type        = map(string)
  default     = {}
}
