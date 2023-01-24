variable resource_group_name {
  description = "(Required) Specifies the resource group name of the virtual machine"
  type = string
}

variable name {
  description = "(Required) Specifies the name of the virtual machine"
  type = string
}

variable size {
  description = "(Required) Specifies the size of the virtual machine"
  type = string
}

variable "os_disk_image" {
  type        = map(string)
  description = "(Optional) Specifies the os disk image of the virtual machine"
  default     = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS" 
    version   = "latest"
  }
}

variable "os_disk_storage_account_type" {
  description = "(Optional) Specifies the storage account type of the os disk of the virtual machine"
  default     = "StandardSSD_LRS"
  type        = string

  validation {
    condition = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS",  "Standard_LRS"], var.os_disk_storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

variable public_ip {
  description = "(Optional) Specifies whether create a public IP for the virtual machine"
  type = bool
  default = false
}

variable location {
  description = "(Required) Specifies the location of the virtual machine"
  type = string
}

variable domain_name_label {
  description = "(Required) Specifies the DNS domain name of the virtual machine"
  type = string
}

variable subnet_id {
  description = "(Required) Specifies the resource id of the subnet hosting the virtual machine"
  type        = string
}

variable vm_user {
  description = "(Required) Specifies the username of the virtual machine"
  type        = string
  default     = "azadmin"
}
variable "boot_diagnostics_storage_account" {
  description = "(Optional) The Primary/Secondary Endpoint for the Azure Storage Account (general purpose) which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor."
  default     = null
}
variable "tags" {
  description = "(Optional) Specifies the tags of the storage account"
  default     = {}
}

variable "admin_ssh_public_key" {
  description = "Specifies the public SSH key"
  default     = "~/.ssh/aks-tf-ssh-key.pub"
}
variable "admin_ssh_private_key" {
  description = "Specifies the private SSH key"
  default     = "~/.ssh/aks-tf-ssh-key"
}
variable "custom_data" {
  description = "Specifies the base64 encoded custom script to run"
  default     = ""
  type        = string
}

variable "kubeconfig" {
  description = "Specifies the k8s config file"
  default     = "./kubeconfig" 
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
}

variable "log_analytics_workspace_key" {
  description = "Specifies the log analytics workspace key"
  type        = string
}

variable "log_analytics_workspace_resource_id" {
  description = "Specifies the log analytics workspace resource id"
  type        = string
}


variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 7
}
variable "shutdown_time" {
  description = "Specifies the time when the VM auto-shuts down"
  default     = ""
  type        = string
}
variable "shutdown_timezone" {
  description = "Specifies the timezone for auto-shutdown time"
  default     = "W. Europe Standard Time"
  type        = string
}