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

variable "tags" {
  description = "(Optional) Specifies the tags of the storage account"
  default     = {}
}

variable "admin_ssh_public_key" {
  description = "Specifies the public SSH key"
  default     = "~/.ssh/aks-tf-ssh-key.pub"
}
variable "custom_data" {
  description = "Specifies the base64 encoded custom script to run"
  default     = ""
  type        = string
}