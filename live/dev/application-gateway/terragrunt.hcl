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
    application_gateway_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock/subnets/mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "virtual_machine" {
  config_path = "../virtual-machine"

  mock_outputs = {
    private_ip_address = "10.10.1.4"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "../../../modules/application-gateway"
}

inputs = {
  name                = "agw-${local.env.project_name}-${local.env.environment}"
  public_ip_name      = "pip-agw-${local.env.project_name}-${local.env.environment}"
  resource_group_name = dependency.resource_group.outputs.name
  location            = dependency.resource_group.outputs.location
  subnet_id           = dependency.network.outputs.application_gateway_subnet_id
  backend_ip_addresses = [
    dependency.virtual_machine.outputs.private_ip_address
  ]

  sku_name         = local.env.application_gateway_sku_name
  sku_tier         = local.env.application_gateway_sku_tier
  capacity         = local.env.application_gateway_capacity
  frontend_port    = local.env.application_gateway_frontend_port
  backend_port     = local.env.application_gateway_backend_port
  backend_protocol = local.env.application_gateway_backend_protocol
  backend_path     = local.env.application_gateway_backend_path
  request_timeout  = local.env.application_gateway_request_timeout
  rule_priority    = local.env.application_gateway_rule_priority
  enable_http2     = local.env.application_gateway_enable_http2

  tags = local.env.tags
}
