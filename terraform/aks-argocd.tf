resource "kubernetes_namespace" "infrastructure-argocd" {
  metadata {
    name = "infrastructure-argocd"

    labels = {
      app = "kubed"
    }
  }
}

resource "helm_release" "argocd" {
  name  = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "infrastructure-argocd"
  version          = "5.45.0"
  create_namespace = true

  values = [
    file("argocd/application.yaml")
  ]
}