variable "name" {
  description = "Azure Bastion Host name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "bastion_subnet_id" {
  description = "AzureBastionSubnet resource ID"
  type        = string
}

variable "sku" {
  description = "Azure Bastion SKU"
  type        = string
  default     = "Basic"

  validation {
    condition = contains([
      "Basic",
      "Standard",
      "Premium"
    ], var.sku)

    error_message = "Bastion SKU must be Basic, Standard, or Premium."
  }
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}