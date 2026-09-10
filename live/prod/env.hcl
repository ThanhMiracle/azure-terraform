locals {
  environment  = "prod"
  project_name = "platform"
  location     = "japanwest"

  address_space       = ["10.20.0.0/16"]
  app_subnet_prefixes = ["10.20.1.0/24"]

  tags = {
    environment = local.environment
    project     = local.project_name
    managed_by  = "terragrunt"
  }
}
