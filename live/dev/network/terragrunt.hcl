include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

dependency "resource_group" {
  config_path = "../resource-group"

  mock_outputs = {
    name     = "rg-${local.env.project_name}-${local.env.environment}"
    location = local.env.location
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "../../../modules/network"
}

inputs = {
  name                = "vnet-${local.env.project_name}-${local.env.environment}"
  resource_group_name = dependency.resource_group.outputs.name
  location            = dependency.resource_group.outputs.location
  address_space       = local.env.address_space
  app_subnet_name     = "snet-app"
  app_subnet_prefixes = local.env.app_subnet_prefixes
  tags                = local.env.tags
}
