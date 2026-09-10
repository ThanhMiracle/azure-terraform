include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/virtual-machine"
}

dependency "resource_group" {
  config_path = "../resource-group"
}

dependency "network" {
  config_path = "../network"
}

dependencies {
  paths = ["../network-security-group"]
}

inputs = {
  name = "vm-${local.env.locals.project_name}-${local.env.locals.environment}"

  resource_group_name = dependency.resource_group.outputs.name
  location            = local.env.locals.location

  subnet_id = dependency.network.outputs.app_subnet_id

  vm_size                      = local.env.locals.vm_size
  admin_username               = local.env.locals.vm_admin_username
  os_disk_storage_account_type = local.env.locals.vm_os_disk_storage_account_type
  public_ip_enabled            = local.env.locals.vm_public_ip_enabled

  admin_password = get_env("VM_ADMIN_PASSWORD")

  tags = local.env.locals.tags
}
