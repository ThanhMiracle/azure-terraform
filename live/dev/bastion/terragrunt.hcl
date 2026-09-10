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

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    name     = "rg-${local.env.project_name}-${local.env.environment}"
    location = local.env.location
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "../../../modules/bastion"
}

inputs = {
  name = "bas-${local.env.project_name}-${local.env.environment}"

  resource_group_name = dependency.resource_group.outputs.name
  location            = dependency.resource_group.outputs.location

  bastion_subnet_id = dependency.network.outputs.bastion_subnet_id

  sku = local.env.bastion_sku

  tags = local.env.tags
}