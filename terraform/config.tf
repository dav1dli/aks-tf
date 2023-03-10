terraform {
  required_version = "~> 1.2.9"
  required_providers {
    azurerm    = {
      source   = "hashicorp/azurerm"
    }
    kubernetes = {
      source   = "hashicorp/kubernetes"
    }
  }
  backend "azurerm" {}
}
provider "azurerm" {
  features {}
}