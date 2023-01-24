output "id" {
  value       = azurerm_kubernetes_cluster.aks_cluster.id
  description = "Specifies the ID of the AKS cluster."
}
output "name" {
  value       = azurerm_kubernetes_cluster.aks_cluster.name
  description = "Specifies the name of the AKS cluster."
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  description = "Specifies the resource id of the Resource Group which contains the resources for this Managed Kubernetes Cluster."
}

output "aks_cluster_kubernetes_version" {
  value = azurerm_kubernetes_cluster.aks_cluster.kubernetes_version
}

output "aks_cluster_managed_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
}

resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.aks_cluster]
  filename     = "kubeconfig"
  content      = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}
output "kv_secret_provider_client_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.key_vault_secrets_provider[0].secret_identity[0].client_id
  description = "Specifies the client ID of the AKS cluster KV secret provider."
}
output "kv_secret_provider_object_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.key_vault_secrets_provider[0].secret_identity[0].object_id
  description = "Specifies the object ID of the AKS cluster KV secret provider."
}
output "kv_secret_provider_assigned_identity" {
  value = azurerm_kubernetes_cluster.aks_cluster.key_vault_secrets_provider[0].secret_identity[0].user_assigned_identity_id
  description = "Specifies the user assigned identity of the AKS cluster KV secret provider."
}