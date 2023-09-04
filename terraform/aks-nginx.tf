resource "kubernetes_namespace" "infrastructure-nginx" {
  metadata {
    name = "infrastructure-nginx"
  }
  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "azurerm_role_assignment" "vnet_aks" {
  principal_id                = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  scope                       = azurerm_virtual_network.infra-vnet.id
  role_definition_name        =  "Network Contributor"

  depends_on = [kubernetes_namespace.infrastructure-nginx]
}

resource "helm_release" "infrastructure-nginx-ingress" {
  name      = "ingress-nginx"
  namespace = kubernetes_namespace.infrastructure-nginx.metadata[0].name

  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.7.1"


  depends_on = [
    kubernetes_namespace.infrastructure-nginx,
    azurerm_role_assignment.vnet_aks
  ]
}

