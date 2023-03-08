resource "azurerm_kubernetes_cluster" "dc1" {
  name                = "${local.resource_prefix}-dc1"
  location            = azurerm_resource_group.aks_consul.location
  resource_group_name = azurerm_resource_group.aks_consul.name
  dns_prefix          = "${local.resource_prefix}-dc1"

  default_node_pool {
    name       = "default"
    node_count = var.node_pool_node_count
    vm_size    = var.node_pool_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Demo"
  }
}

resource "local_file" "dc1_kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.dc1]
  filename     = "${var.kubeconfig_directory}/dc1.config"
  content      = azurerm_kubernetes_cluster.dc1.kube_config_raw
}

resource "azurerm_kubernetes_cluster" "dc2" {
  name                = "${local.resource_prefix}-dc2"
  location            = azurerm_resource_group.aks_consul.location
  resource_group_name = azurerm_resource_group.aks_consul.name
  dns_prefix          = "${local.resource_prefix}-dc2"

  default_node_pool {
    name       = "default"
    node_count = var.node_pool_node_count
    vm_size    = var.node_pool_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Demo"
  }
}

resource "local_file" "dc2_kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.dc2]
  filename     = "${var.kubeconfig_directory}/dc2.config"
  content      = azurerm_kubernetes_cluster.dc2.kube_config_raw
}
