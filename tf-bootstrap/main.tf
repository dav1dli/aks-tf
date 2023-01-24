data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "tfstate" {
    name     = local.resource_group
    location = var.location
    tags     = var.tags
}
resource "azurerm_storage_account" "tfstate" {
  name                              = local.storage_account
  resource_group_name               = azurerm_resource_group.tfstate.name
  location                          = azurerm_resource_group.tfstate.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  infrastructure_encryption_enabled = true
  tags                              = var.tags
  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes = [
        tags
    ]
    prevent_destroy = true
  }
}
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
resource "azurerm_storage_account_network_rules" "tfstate" {
  storage_account_id = azurerm_storage_account.tfstate.id
  default_action             = "Deny"
  ip_rules                   = local.client_ips
  bypass                     = ["AzureServices"]
  depends_on = [
    azurerm_storage_container.tfstate
  ]
}