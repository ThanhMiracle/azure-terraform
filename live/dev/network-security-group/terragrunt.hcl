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
    app_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock/subnets/mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "../../../modules/network-security-group"
}

inputs = {
  name                      = "nsg-${local.env.project_name}-${local.env.environment}"
  resource_group_name       = dependency.resource_group.outputs.name
  location                  = dependency.resource_group.outputs.location
  subnet_id                 = dependency.network.outputs.app_subnet_id
  ssh_source_address_prefix = get_env("SSH_SOURCE_ADDRESS_PREFIX", "*")
  tags                      = local.env.tags
}
