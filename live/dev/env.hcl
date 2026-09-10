locals {
  environment  = "dev"
  project_name = "platform"
  location     = "japanwest"

  address_space       = ["10.10.0.0/16"]
  app_subnet_prefixes = ["10.10.1.0/24"]

  # NSG
  ssh_source_address_prefix = "10.10.3.0/26"
  ssh_destination_port      = "22"
  
  # Bastion
  bastion_subnet_prefixes = ["10.10.3.0/26"]
  bastion_sku             = "Basic"

  # Application Gateway
  application_gateway_subnet_name      = "snet-appgw"
  application_gateway_subnet_prefixes  = ["10.10.2.0/24"]
  application_gateway_sku_name         = "Standard_v2"
  application_gateway_sku_tier         = "Standard_v2"
  application_gateway_capacity         = 1
  application_gateway_frontend_port    = 80
  application_gateway_backend_port     = 80
  application_gateway_backend_protocol = "Http"
  application_gateway_backend_path     = "/"
  application_gateway_request_timeout  = 30
  application_gateway_rule_priority    = 100
  application_gateway_enable_http2     = true

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
