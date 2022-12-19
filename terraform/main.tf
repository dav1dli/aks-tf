data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "rg" {
    name     = local.resource_group
    location = var.location
    tags     = var.tags
}

module "log_analytics_workspace" {
  source                           = "./modules/analytics"
  name                             = local.log_analytics_workspace_name
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
}

module "aks_network" {
    source              = "./modules/virtual_network"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    vnet_name           = local.vnet_name
    address_space       = var.aks_vnet_address_space
    
    subnets = [
        {
          name : local.nodes_subnet
          address_prefixes : var.nodes_subnet_address_prefix
        },
        {
          name : local.pods_subnet
          address_prefixes : var.pods_subnet_address_prefix
        },
        {
          name : local.bstn_subnet
          address_prefixes : var.bstn_subnet_address_prefix
        },
        {
          name : local.mng_subnet
          address_prefixes : var.mng_subnet_address_prefix
        },
  ]
}

module "acr" {
  source                       = "./modules/acr"
  name                         = local.acr_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  sku                          = var.acr_sku
  admin_enabled                = var.acr_admin_enabled
}

module "key_vault" {
  source                          = "./modules/keyvault"
  name                            = local.kv_name
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_name
  tags                            = var.tags
  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  bypass                          = var.key_vault_bypass
  default_action                  = var.key_vault_default_action
}

module "aks_cluster" {
  source                                   = "./modules/aks"
  name                                     = local.cluster_name
  location                                 = azurerm_resource_group.rg.location
  resource_group_name                      = azurerm_resource_group.rg.name
  kubernetes_version                       = var.kubernetes_version
  node_resource_group                      = local.node_resource_group
  dns_prefix                               = lower(local.cluster_name)
  private_cluster_enabled                  = false
  default_node_pool_name                   = var.default_node_pool_name
  default_node_pool_vm_size                = var.default_node_pool_vm_size
  vnet_subnet_id                           = module.aks_network.subnet_ids[local.nodes_subnet]
  pods_subnet_id                           = module.aks_network.subnet_ids[local.pods_subnet]
  default_node_pool_availability_zones     = var.default_node_pool_availability_zones
  default_node_pool_node_labels            = var.default_node_pool_node_labels
  default_node_pool_enable_auto_scaling    = var.default_node_pool_enable_auto_scaling
  default_node_pool_max_pods               = var.default_node_pool_max_pods
  default_node_pool_max_count              = var.default_node_pool_max_count
  default_node_pool_min_count              = var.default_node_pool_min_count
  default_node_pool_node_count             = var.default_node_pool_node_count
  tags                                     = var.tags
  network_docker_bridge_cidr               = var.network_docker_bridge_cidr
  network_dns_service_ip                   = var.network_dns_service_ip
  network_plugin                           = var.network_plugin
  network_service_cidr                     = var.network_service_cidr
  admin_username                           = var.admin_username
  ssh_public_key                           = var.ssh_public_key
  log_analytics_workspace_id               = module.log_analytics_workspace.id

  depends_on                               = [module.aks_network, module.log_analytics_workspace]
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                            = azurerm_resource_group.rg.id
  role_definition_name             = "Network Contributor"
  principal_id                     = module.aks_cluster.aks_cluster_managed_id
  skip_service_principal_aad_check = true
}
resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = module.aks_cluster.aks_cluster_managed_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.id
  skip_service_principal_aad_check = true
}

module "jumphost" {
  source                       = "./modules/vm"
  name                         = local.jump_host_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  public_ip                    = var.vm_public_ip
  vm_user                      = var.admin_username
  admin_ssh_public_key         = file(var.ssh_public_key)
  size                         = var.vm_size
  os_disk_image                = var.vm_os_disk_image
  domain_name_label            = lower(local.jump_host_name)
  subnet_id                    = module.aks_network.subnet_ids[local.mng_subnet]
  custom_data                  = filebase64("files/mng-vm-init.sh")
  depends_on                   = [module.aks_network]
}

# Use bastion to connect to management VM / jumphost:
# select the jumphost in Azure portal, click Connect, select Bastion
# specify username: the admin user, authentication type: SSH private key, 
# File: SSH private key. Click Connect. A shell session will open in a web browser.
module "bastion" {
  source                       = "./modules/bastion"
  name                         = local.bastion_name
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  subnet_id                    = module.aks_network.subnet_ids[local.bstn_subnet]
  depends_on                   = [module.aks_network]
}