locals {
  resource_group               = "RG-${var.region}-${var.environment}-${var.project}"
  tfstate_stor_account         = lower("sa${var.environment}${var.project}tfstate")
  tfstate_stor_container       = "tfstate"
  node_resource_group          = "RG-AKS-${var.region}-${var.environment}-${var.project}"
  vnet_name                    = "VNET-${var.region}-${var.environment}-${var.project}"
  nodes_subnet                 = "SBNT-NODES-${var.region}-${var.environment}-${var.project}"
  pods_subnet                  = "SBNT-PODS-${var.region}-${var.environment}-${var.project}"
  bstn_subnet                  = "AzureBastionSubnet"
  mng_subnet                   = "SBNT-MNG-${var.region}-${var.environment}-${var.project}"
  priv_endpt_subnet            = "SBNT-PEP-${var.region}-${var.environment}-${var.project}"
  acr_name                     = "ACR${var.environment}${var.project}"
  acr_pep_name                 = "PEP-ACR-${var.region}-${var.environment}-${var.project}"
  cluster_name                 = "AKS-${var.region}-${var.environment}-${var.project}"
  ingress_host_name            = "AKS${var.region}${var.environment}${var.project}"
  kv_name                      = "KV-${var.region}-${var.environment}-${var.project}"
  kv_pep_name                  = "PEP-KV-${var.region}-${var.environment}-${var.project}"
  log_analytics_workspace_name = "LAW-${var.region}-${var.environment}-${var.project}"
  jump_host_name               = "LX${var.environment}${var.project}"
  bastion_name                 = "BSTN-${var.region}-${var.environment}-${var.project}"
  storage_account_prefix       = "sa${var.environment}${var.project}"
  storage_account_pep_name     = "PEP-BLOB-${var.region}-${var.environment}-${var.project}"
}