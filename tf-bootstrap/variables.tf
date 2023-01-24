variable "region" {
  type = string  
  description = "Environment region"  
  default = "EURWW"
}
variable "location" {
  type = string
  description = "Azure Region where resources will be provisioned"
  default = "westeurope"
}
variable "environment" {
  type = string  
  description = "Environment"  
  default = ""
}
variable "project" {
  type = string  
  description = "Application project"  
  default = ""
}
variable "tags" {
  description = "Specifies tags for all the resources"
  default     = {
    createdWith = "Terraform"
  }
}