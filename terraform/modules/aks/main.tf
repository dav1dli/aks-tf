terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
  include_preview = false
}
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                     = var.name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  kubernetes_version       = var.kubernetes_version
  node_resource_group      = var.node_resource_group
  dns_prefix               = var.dns_prefix
  private_cluster_enabled  = var.private_cluster_enabled
  azure_policy_enabled     = var.azure_policy_enabled
  default_node_pool {
    name                   = var.default_node_pool_name
    zones                  = var.default_node_pool_availability_zones
    type                   = var.default_node_pool_name_type
    enable_auto_scaling    = var.default_node_pool_enable_auto_scaling
    max_count              = var.default_node_pool_max_count
    min_count              = var.default_node_pool_min_count
    node_count             = var.default_node_pool_node_count
    vm_size                = var.default_node_pool_vm_size
    max_pods               = var.default_node_pool_max_pods
    vnet_subnet_id         = var.vnet_subnet_id
    pod_subnet_id          = var.pods_subnet_id
    node_labels            = var.default_node_pool_node_labels
    only_critical_addons_enabled = true
    tags                   = var.tags
  }

  identity {
    type = "SystemAssigned"
  }
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }
  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
  network_profile {
    network_plugin     = var.network_plugin
    docker_bridge_cidr = var.network_docker_bridge_cidr
    service_cidr       = var.network_service_cidr
    dns_service_ip     = var.network_dns_service_ip
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      tags
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user"  {
  name                   = var.user_node_pool_name
  zones                  = var.user_node_pool_availability_zones
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size                = var.user_node_pool_vm_size
  enable_auto_scaling    = var.user_node_pool_enable_auto_scaling
  max_count              = var.user_node_pool_max_count
  min_count              = var.user_node_pool_min_count
  vnet_subnet_id         = var.vnet_subnet_id
  pod_subnet_id          = var.pods_subnet_id
  max_pods               = var.user_node_pool_max_pods
  mode                   = var.user_node_pool_mode
  tags                   = var.tags
  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster,
  ]
  lifecycle {
    ignore_changes = [
        tags
    ]
  }
}