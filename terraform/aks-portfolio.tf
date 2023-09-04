resource "kubernetes_namespace" "portfolio" {
  metadata {
    name = "portfolio"

    labels = {
      app = "kubed"
    }
  }
}