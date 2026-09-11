variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "app_subnet_name" {
  type    = string
  default = "snet-app"
}

variable "app_subnet_prefixes" {
  type = list(string)
}

variable "application_gateway_subnet_name" {
  description = "Name of the dedicated Application Gateway subnet"
  type        = string
}

variable "application_gateway_subnet_prefixes" {
  description = "Address prefixes for the dedicated Application Gateway subnet"
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "bastion_subnet_prefixes" {
  description = "Address prefixes for Azure Bastion subnet"
  type        = list(string)
}