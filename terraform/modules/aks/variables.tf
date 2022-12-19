variable "name" {
  description = "(Required) Specifies the name of the AKS cluster."
  type        = string
}
variable "resource_group_name" {
  description = "(Required) Specifies the name of the resource group."
  type        = string
}
variable "node_resource_group" {
  description = "(Optional) Specifies the name of the node resource group."
  type        = string
}
variable "location" {
  description = "(Required) Specifies the location where the AKS cluster will be deployed."
  type        = string
}
variable "dns_prefix" {
  description = "(Optional) DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created."
  type        = string
}

variable "private_cluster_enabled" {
  description = "Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}
variable "azure_policy_enabled" {
  description = "Specifies the Azure Policy addon configuration."
  type        = bool
  default     = true
}

variable "kubernetes_version" {
  description = "Specifies the AKS Kubernetes version"
  default     = "1.24"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "(Optional) The ID of the Log Analytics Workspace which the OMS Agent should send data to. Must be present if enabled is true."
  type        = string
}

variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 30
}

variable "tags" {
  description = "(Optional) Specifies the tags of the bastion host"
  default     = {}
}
variable "vnet_subnet_id" {
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist."
  type        = string
}
variable "pods_subnet_id" {
  description = "(Optional) The ID of a Subnet where the Kubernetes pods should run."
  type        = string
}
# System node pool
variable "default_node_pool_name" {
  description = "Specifies the name of the default node pool"
  default     =  "systempool"
  type        = string
}
variable "default_node_pool_availability_zones" {
  description = "Specifies the availability zones of the default node pool"
  default     = ["1", "2", "3"]
  type        = list(string)
}
variable "default_node_pool_vm_size" {
  description = "Specifies the vm size of the default node pool"
  default     = "Standard_DS3_v2"
  type        = string
}
variable "default_node_pool_name_type" {
  description = "Specifies the type of the default node pool"
  default     =  "VirtualMachineScaleSets"
  type        = string
}
variable "default_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type          = bool
  default       = true
}
variable "default_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type          = number
  default       = 3
}
variable "default_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type          = number
  default       = 3
}
variable "default_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type          = number
  default       = 3
}
variable "default_node_pool_node_labels" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type          = map(any)
  default       = {}
} 
variable "default_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type          = number
  default       = 30
}

# Users node pool
variable "user_node_pool_name" {
  description = "Specifies the name of the users node pool"
  default     =  "userpool"
  type        = string
}
variable "user_node_pool_availability_zones" {
  description = "Specifies the availability zones of the users node pool"
  default     = ["1", "2", "3"]
  type        = list(string)
}

variable "user_node_pool_vm_size" {
  description = "Specifies the vm size of the users node pool"
  default     = "Standard_DS3_v2"
  type        = string
}

variable "user_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler."
  type          = bool
  default       = true
}
variable "user_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type          = number
  default       = 10
}

variable "user_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type          = number
  default       = 1
}
variable "user_node_pool_mode" {
  description = "Specifies the mode of the user node pool"
  default     =  "User"
  type        = string
}
variable "user_node_pool_node_labels" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule)."
  type          = map(any)
  default       = {}
} 

variable "user_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent."
  type          = number
  default       = 110
}
variable "admin_username" {
  description = "(Required) Specifies the Admin Username for the AKS cluster worker nodes. Changing this forces a new resource to be created."
  type        = string
  default     = "azureuser"
}
variable "ssh_public_key" {
  default = "~/.ssh/aks-tf-ssh-key.pub"
  description = "This variable defines the SSH Public Key for Linux k8s Worker nodes"  
}
variable "network_docker_bridge_cidr" {
  description = "Specifies the Docker bridge CIDR"
  default     = "172.17.0.1/16"
  type        = string
}

variable "network_dns_service_ip" {
  description = "Specifies the DNS service IP"
  default     = "10.1.0.10"
  type        = string
}

variable "network_service_cidr" {
  description = "Specifies the service CIDR"
  default     = "10.1.0.0/16"
  type        = string
}
variable "network_plugin" {
  description = "Specifies the network plugin of the AKS cluster"
  default     = "azure"
  type        = string
}