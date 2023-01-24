output "env" {
  value = var.environment
}
output "location" {
  value = azurerm_resource_group.rg.location
}
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
output "aks_name" {
  value = module.aks_cluster.name
}
output "ingress_public_ip" {
  value = azurerm_public_ip.ingress_ip.ip_address
}
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
output "aks_kv_secret_provider_client_id" {
  value = module.aks_cluster.kv_secret_provider_client_id
}
output "jumphost_public_ip" {
  value = module.jumphost.public_ip
}
output "kv_name" {
  value = module.key_vault.name
}