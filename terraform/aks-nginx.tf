resource "kubernetes_namespace" "infrastructure-nginx" {
  metadata {
    name = "infrastructure-nginx"
  }
}

resource "kubernetes_config_map" "infrastructure-nginx-ingress-config" {
  metadata {
    name      = "nginx-ingress-config"
    namespace = kubernetes_namespace.infrastructure-nginx.metadata[0].name
  }
  data = {
    "proxy-buffer-size"       = "128k"
    "proxy-buffers"           = "4 256k"
    "proxy-busy-buffers-size" = "256k"
  }

  depends_on = [kubernetes_namespace.infrastructure-nginx]
}

resource "helm_release" "infrastructure-nginx-ingress" {
  name      = "nginx-ingress"
  namespace = kubernetes_namespace.infrastructure-nginx.metadata[0].name

  chart      = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  version    = "0.17.1"

  values = [
    file("aks-nginx-values.yml")
  ]

  depends_on = [
    kubernetes_namespace.infrastructure-nginx,
    kubernetes_config_map.infrastructure-nginx-ingress-config,
    azurerm_role_assignment.vnet_aks
  ]
}

resource "azurerm_role_assignment" "vnet_aks" {
  principal_id                = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  scope                       = azurerm_virtual_network.infra-vnet.id
  role_definition_name        =  "Network Contributor"
}