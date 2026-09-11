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
  description = "Source CIDR allowed to connect via SSH"
  type        = string
}

variable "tags" {
  description = "Tags applied to the network security group"
  type        = map(string)
  default     = {}
}
variable "ssh_destination_port" {
  description = "Destination port for SSH"
  type        = string
  default     = "22"
}