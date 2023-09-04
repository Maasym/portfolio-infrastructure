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

  depends_on = [kubernetes_namespace.infrastructure-argocd]
}

resource "kubectl_manifest" "argocd-ingress" {
  yaml_body  = <<-EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-http-ingress
  namespace: infrastructure-argocd
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - argocd.spech.dev
    secretName: spech-dev-tls
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              name: https
    host: argocd.spech.dev

    EOF

  depends_on = [helm_release.argocd]
}