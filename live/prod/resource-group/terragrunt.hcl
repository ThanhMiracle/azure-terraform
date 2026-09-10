include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "../../../modules/resource-group"
}

inputs = {
  name     = "rg-${local.env.project_name}-${local.env.environment}"
  location = local.env.location
  tags     = local.env.tags
}
