resource "azurerm_kubernetes_cluster" "aks" {
  location            = azurerm_resource_group.infra.location
  name                = "aks"
  resource_group_name = azurerm_resource_group.infra.name
  dns_prefix          = "aks"
  sku_tier            = "Free"

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  default_node_pool {
    name            = "agentpool"
    vm_size         = "Standard_B2s"
    node_count      = "1"
    vnet_subnet_id  = azurerm_subnet.aks-subnet.id
    os_disk_size_gb = "32"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "basic"
  }
}