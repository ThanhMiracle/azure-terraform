param(
  [string]$BootstrapPath = "../bootstrap"
)

$ErrorActionPreference = "Stop"

$account = az account show | ConvertFrom-Json
$env:ARM_SUBSCRIPTION_ID = $account.id
$env:ARM_TENANT_ID = $account.tenantId

Push-Location $BootstrapPath
try {
  $env:TF_STATE_STORAGE_ACCOUNT = terraform output -raw storage_account_name
  $env:TF_STATE_RESOURCE_GROUP  = terraform output -raw resource_group_name
  $env:TF_STATE_CONTAINER       = terraform output -raw container_name
}
finally {
  Pop-Location
}

Write-Host "ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID"
Write-Host "ARM_TENANT_ID=$env:ARM_TENANT_ID"
Write-Host "TF_STATE_STORAGE_ACCOUNT=$env:TF_STATE_STORAGE_ACCOUNT"
Write-Host "TF_STATE_RESOURCE_GROUP=$env:TF_STATE_RESOURCE_GROUP"
Write-Host "TF_STATE_CONTAINER=$env:TF_STATE_CONTAINER"
