variable "resource_prefix" {
  default  = "aks-consul"
}

variable "region" {
  default = "West US 2"
}

variable "node_pool_node_count" {
  default = 1
}

variable "node_pool_vm_size" {
  default = "Standard_D3_v2"
}

variable "kubeconfig_directory" { }
