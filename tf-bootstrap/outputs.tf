output "resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}
output "location" {
  value = azurerm_resource_group.tfstate.location
}
output "storage_account_name" {
    description = "Specifies the name of the storage account"
    value       = azurerm_storage_account.tfstate.name
}

output "storage_account_id" {
    description = "Specifies the resource id of the storage account"
    value       = azurerm_storage_account.tfstate.id
}

output "storage_account_primary_access_key" {
    description = "Specifies the primary access key of the storage account"
    value       = azurerm_storage_account.tfstate.primary_access_key
    sensitive   = true
}

output "storage_account_principal_id" {
    description = "Specifies the principal id of the system assigned managed identity of the storage account"
    value       = azurerm_storage_account.tfstate.identity[0].principal_id
}
output "storage_container_id" {
    description = "Specifies the resource id of the storage container"
    value       = azurerm_storage_container.tfstate.id
}