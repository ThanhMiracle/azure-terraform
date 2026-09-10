variable "subscription_id" {
  description = "Azure subscription ID used to create the Terraform state backend."
  type        = string
}

variable "location" {
  description = "Azure region for the state resource group and storage account."
  type        = string
  default     = "japanwest"
}

variable "resource_group_name" {
  description = "Resource group containing the Terraform state storage account."
  type        = string
  default     = "rg-platform-tfstate"
}


variable "container_name" {
  description = "Blob container used for Terraform state files."
  type        = string
  default     = "tfstate"
}

variable "storage_account_name" {
  description = "Storage account used for Terraform remote state"
  type        = string
}
