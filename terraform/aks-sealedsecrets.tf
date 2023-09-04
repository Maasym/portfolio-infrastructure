resource "kubernetes_namespace" "infrastructure-sealedsecrets" {
  metadata {
    name = "infrastructure-sealedsecrets"
  }
  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "helm_release" "sealedsecrets" {
  name       = "sealed-secrets"
  namespace  = kubernetes_namespace.infrastructure-sealedsecrets.metadata.0.name

  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = "v2.12.0"

  depends_on = [kubernetes_namespace.infrastructure-sealedsecrets]
}