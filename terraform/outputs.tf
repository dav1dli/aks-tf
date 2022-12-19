output "location" {
  value = azurerm_resource_group.rg.location
}
output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
# output "aks_name" {
#   value = module.aks_cluster.name
# }
# output "aks_version" {
#   value = module.aks_cluster.aks_cluster_kubernetes_version
# }
output "jumphost_public_ip" {
  value = module.jumphost.public_ip
}