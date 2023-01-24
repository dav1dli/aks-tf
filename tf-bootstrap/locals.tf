locals {
  resource_group               = "RG-${var.region}-${var.environment}-${var.project}"
  storage_account              = lower("sa${var.environment}${var.project}tfstate")
  client_ips                   = ["123.10.20.0/17"]
}