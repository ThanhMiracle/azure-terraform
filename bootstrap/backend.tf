# OPTIONAL: after the state storage account exists, rename this file to backend.tf
# and run terraform init -migrate-state with the backend values.
terraform {
  backend "azurerm" {}
}
