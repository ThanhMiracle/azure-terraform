# Azure Terraform + Terragrunt + Blob State

This starter separates reusable Terraform modules from Terragrunt environment configuration.
Application infrastructure state is stored in an Azure Blob Storage container, with one state blob per Terragrunt unit.

## Layout

```text
azure-terragrunt-blob-state/
├── bootstrap/                 # One-time creation of the remote-state storage
├── modules/
│   ├── resource-group/
│   └── network/
├── live/
│   ├── root.hcl               # Generates backend.tf + provider.tf
│   ├── dev/
│   │   ├── env.hcl
│   │   ├── resource-group/terragrunt.hcl
│   │   └── network/terragrunt.hcl
│   └── prod/
│       ├── env.hcl
│       ├── resource-group/terragrunt.hcl
│       └── network/terragrunt.hcl
└── scripts/set-backend-env.ps1
```

The state blobs will look like:

```text
tfstate/
├── dev/resource-group/terraform.tfstate
├── dev/network/terraform.tfstate
├── prod/resource-group/terraform.tfstate
└── prod/network/terraform.tfstate
```

## 1. Prerequisites

Install and authenticate:

- Azure CLI
- Terraform
- Terragrunt

```powershell
az login
az account set --subscription "<subscription-id>"
```

## 2. Bootstrap the Blob backend

The backend must exist before Terraform/Terragrunt can store state in it.
The bootstrap directory therefore starts with local state.

```powershell
cd bootstrap
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`, then:

```powershell
terraform init
terraform plan
terraform apply
terraform output
```

The storage account has Blob versioning and 14-day soft delete enabled. Shared Key remains enabled during bootstrap so Terraform can reliably create/manage the container. Terragrunt itself is configured to authenticate to the state backend with Microsoft Entra ID/Azure CLI, not with the account key.

If you later want to disable Shared Key on this state account, first grant the Terraform identity an appropriate Storage Blob data role and configure the AzureRM provider used to manage Blob resources with `storage_use_azuread = true`.

## 3. Grant Blob data-plane access

The identity running Terragrunt needs **Storage Blob Data Contributor** (or a stronger Blob data role) on the state container/storage account.
Azure `Contributor` on the resource group is not enough for Blob data access.

If your current account is allowed to create role assignments:

```powershell
$storageId = terraform output -raw storage_account_id
$me = az ad signed-in-user show --query id -o tsv
az role assignment create `
  --assignee-object-id $me `
  --assignee-principal-type User `
  --role "Storage Blob Data Contributor" `
  --scope $storageId
```

If that command returns `Microsoft.Authorization/roleAssignments/write` denied, an Owner or User Access Administrator must grant the role for you.

## 4. Export backend environment variables

From the repository root:

```powershell
$account = az account show | ConvertFrom-Json
$env:ARM_SUBSCRIPTION_ID = $account.id
$env:ARM_TENANT_ID = $account.tenantId
$env:TF_STATE_STORAGE_ACCOUNT = "YOUR_STORAGE_ACCOUNT_NAME"

cd bootstrap
$env:TF_STATE_STORAGE_ACCOUNT = terraform output -raw storage_account_name
$env:TF_STATE_RESOURCE_GROUP  = terraform output -raw resource_group_name
$env:TF_STATE_CONTAINER       = terraform output -raw container_name
cd ..
```

Or run the helper script from `scripts/`:

```powershell
cd scripts
. ./set-backend-env.ps1
cd ..
```

Keep the variables in the same PowerShell process that runs Terragrunt.

## 5. Deploy dev with Terragrunt

Deploy the dependency first:

```powershell
cd live/dev/resource-group
terragrunt init -reconfigure
terragrunt plan
terragrunt apply

cd ../network
terragrunt init -reconfigure
terragrunt plan
terragrunt apply
```

Or from `live/dev`, let Terragrunt use its dependency graph:

```powershell
terragrunt run --all plan
terragrunt run --all apply
```

$env:VM_ADMIN_PASSWORD = "YourStrongPasswordHere!"
$env:SSH_SOURCE_ADDRESS_PREFIX = "$(Invoke-RestMethod 'https://api.ipify.org')/32"
## 6. Verify state in Azure Blob Storage

```powershell
az storage blob list `
  --account-name $env:TF_STATE_STORAGE_ACCOUNT `
  --container-name $env:TF_STATE_CONTAINER `
  --auth-mode login `
  --query "[].name" `
  -o table
```

You should see state paths such as:

```text
dev/resource-group/terraform.tfstate
dev/network/terraform.tfstate
```

## Optional: migrate bootstrap's own state to Blob

The application states are already remote. If you also want the small bootstrap state to live in Blob Storage, first create the backend as above, then rename `bootstrap/backend.tf.example` to `bootstrap/backend.tf` and run:

```powershell
cd bootstrap
terraform init -migrate-state `
  -backend-config="resource_group_name=$env:TF_STATE_RESOURCE_GROUP" `
  -backend-config="storage_account_name=$env:TF_STATE_STORAGE_ACCOUNT" `
  -backend-config="container_name=$env:TF_STATE_CONTAINER" `
  -backend-config="key=bootstrap/terraform.tfstate" `
  -backend-config="use_azuread_auth=true" `
  -backend-config="use_cli=true" `
  -backend-config="subscription_id=$env:ARM_SUBSCRIPTION_ID" `
  -backend-config="tenant_id=$env:ARM_TENANT_ID"
```

After a successful migration, `bootstrap/terraform.tfstate` is also stored in the same Blob container.

## Why `generate "backend"` instead of Terragrunt Azure auto-bootstrap?

Terragrunt can configure an `azurerm` `remote_state` block, but its Azure backend bootstrap/delete/migrate support is currently experimental. This starter therefore uses ordinary Terraform to bootstrap the storage once and Terragrunt to generate a stable `backend.tf` for each infrastructure unit.

## Adding another unit

For example, to add a VM:

```text
modules/virtual-machine/
live/dev/virtual-machine/terragrunt.hcl
live/prod/virtual-machine/terragrunt.hcl
```

Include `root.hcl`, point `terraform.source` to the module, declare `dependency` blocks for resources such as the network, and pass values through `inputs`. The state key will be generated automatically from the folder path.
