provider "azurerm" {
  features { }
}

resource "random_string" "resource_infix" {
  numeric = false
  length  = 5
  upper   = false
  special = false
}

locals {
  resource_prefix = "aks-consul"
  resource_infix  = resource.random_string.resource_infix.id
  region          = var.region
}

resource "azurerm_resource_group" "aks_consul" {
  name     = local.resource_prefix
  location = local.region
}
