resource "kubernetes_namespace" "infrastructure-kubed" {
  metadata {
    name = "infrastructure-kubed"
  }
  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "helm_release" "kubed" {
  name       = "kubed"
  namespace  = kubernetes_namespace.infrastructure-kubed.metadata.0.name

  repository = "https://charts.appscode.com/stable/"
  chart      = "kubed"
  version    = "v0.13.2"

  depends_on = [kubernetes_namespace.infrastructure-kubed]
}