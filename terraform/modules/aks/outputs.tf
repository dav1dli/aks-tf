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