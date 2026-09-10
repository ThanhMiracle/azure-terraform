locals {
  environment  = "dev"
  project_name = "platform"
  location     = "japanwest"

  address_space       = ["10.10.0.0/16"]
  app_subnet_prefixes = ["10.10.1.0/24"]

  # VM
  vm_size                         = "Standard_D4s_v3"
  vm_admin_username               = "azureadmin"
  vm_os_disk_storage_account_type = "Standard_LRS"
  vm_public_ip_enabled            = true

  tags = {
    environment = local.environment
    project     = local.project_name
    managed_by  = "terragrunt"
  }
}
