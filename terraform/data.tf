data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_cluster" "aks"{
  depends_on          = [azurerm_kubernetes_cluster.aks]
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = azurerm_resource_group.infra.name
}