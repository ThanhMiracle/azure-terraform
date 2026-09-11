include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../modules/postgresql"
}

dependency "resource_group" {
  config_path = "../resource-group"

  mock_outputs = {
    name     = "rg-${local.env.project_name}-${local.env.environment}"
    location = local.env.location
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vnet_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-${local.env.project_name}-${local.env.environment}/providers/Microsoft.Network/virtualNetworks/vnet-${local.env.project_name}-${local.env.environment}"
    vnet_name = "vnet-${local.env.project_name}-${local.env.environment}"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  name = "psql-${local.env.project_name}-${local.env.environment}-${substr(md5(get_env("ARM_SUBSCRIPTION_ID")), 0, 8)}"

  resource_group_name  = dependency.resource_group.outputs.name
  location             = dependency.resource_group.outputs.location
  virtual_network_id   = dependency.network.outputs.vnet_id
  virtual_network_name = dependency.network.outputs.vnet_name

  subnet_name             = "snet-postgresql"
  subnet_address_prefixes = local.env.postgresql_subnet_prefixes

  administrator_login    = local.env.postgresql_administrator_login
  administrator_password = get_env("POSTGRESQL_ADMIN_PASSWORD")
  postgresql_version     = local.env.postgresql_version
  sku_name               = local.env.postgresql_sku_name
  storage_mb             = local.env.postgresql_storage_mb
  backup_retention_days  = local.env.postgresql_backup_retention_days

  databases = {
    app = {}
  }

  tags = local.env.tags
}
