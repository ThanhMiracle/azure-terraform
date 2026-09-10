locals {
  subscription_id = get_env("ARM_SUBSCRIPTION_ID")
  tenant_id       = get_env("ARM_TENANT_ID")

  state_resource_group_name  = get_env("TF_STATE_RESOURCE_GROUP", "rg-platform-tfstate")
  state_storage_account_name = get_env("TF_STATE_STORAGE_ACCOUNT")
  state_container_name       = get_env("TF_STATE_CONTAINER", "tfstate")
}

# Stable approach for Azure: Terragrunt generates backend.tf for every unit.
# The Storage Account itself is created separately by bootstrap/.
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF_BACKEND
terraform {
  backend "azurerm" {
    resource_group_name  = "${local.state_resource_group_name}"
    storage_account_name = "${local.state_storage_account_name}"
    container_name       = "${local.state_container_name}"
    key                  = "${replace(path_relative_to_include(), "\\", "/")}/terraform.tfstate"

    use_azuread_auth = false
    use_cli          = true
    subscription_id  = "${local.subscription_id}"
    tenant_id        = "${local.tenant_id}"
  }
}
EOF_BACKEND
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF_PROVIDER
provider "azurerm" {
  features {}
  subscription_id = "${local.subscription_id}"
  tenant_id       = "${local.tenant_id}"
}
EOF_PROVIDER
}
