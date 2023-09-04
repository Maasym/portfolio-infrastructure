resource "kubernetes_namespace" "infrastructure-monitoring" {
  metadata {
    name = "infrastructure-monitoring"

    labels = {
      app = "kubed"
    }
  }
}