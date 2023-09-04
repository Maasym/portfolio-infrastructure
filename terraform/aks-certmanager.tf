resource "kubernetes_namespace" "infrastructure-certmanager" {
  metadata {
    name = "infrastructure-certmanager"
  }
  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.7.1"
  namespace  = kubernetes_namespace.infrastructure-certmanager.metadata.0.name

  set {
    name  = "installCRDs"
    value = "true"
  }
  depends_on = [kubernetes_namespace.infrastructure-certmanager]
}

resource "kubectl_manifest" "clusterIssuer-staging" {
  yaml_body  = <<-EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-stg
spec:
  acme:
    email: contact@spech.dev
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: le-issuer-stg-acct-key
    solvers:
      - dns01:
          cloudflare:
            email: leak@go-nihon.com
            apiTokenSecretRef:
              name: cloudflare-api-token-secret
              key: api-token
        selector:
          dnsZones:
            - 'spech.dev'
            - '*.spech.dev'
    EOF
}

resource "kubectl_manifest" "clusterIssuer-prod" {
  yaml_body  = <<-EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: contact@spech.dev
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: le-issuer-prod-acct-key
    solvers:
      - dns01:
          cloudflare:
            email: leak@go-nihon.com
            apiTokenSecretRef:
              name: cloudflare-api-token-secret
              key: api-token
        selector:
          dnsZones:
            - 'spech.dev'
            - '*.spech.dev'
    EOF
}

resource "kubectl_manifest" "spech-dev-tls" {
  yaml_body  = <<-EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: spech-dev-tls
  namespace: infrastructure-certmanager
spec:
  secretName: spech-dev-tls
  secretTemplate:
    annotations:
      kubed.appscode.com/sync: "app=kubed"
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  commonName: '*.spech.dev'
  dnsNames:
    - "*.spech.dev"
    EOF
}

resource "kubectl_manifest" "secret" {
  yaml_body  = <<-EOF
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: cloudflare-api-token-secret
  namespace: infrastructure-certmanager
spec:
  encryptedData:
    api-token: AgBH4GGwAFYR/akqPsQRufAWRJpxQkOYZWQaEODyAeJS3vwNYbkNeiGD1CrkBXaEU8IgEC2J3sXepfoh05ZfVav1n4l7F9qJQeYIhU8A8zKijUHEkT+9fmWJe1IRW4uWarEUts3+X1X5onNpcOES65w/nW2a8QqXekxChIGcvd8/8y9qwKhWOM7TT/NGszGoUh47TRYQGqohSSAkBGIaGueoygQdLN86qha8bKhj7Yo/IUY8dqoVB+cNp9UFRPA9kx/8ixmUEN2AZ/Qp5Sz+7cRbtEXEtr0WafJRtXAapBjTUaq9EkVjMjRXi7nq1eQu/RiuSRIcBl93d6j8HkXfyJSV7E0K+lGp6PwreWCzLzezACP8rAzdcMGG8vdha0NI6b+JFfC8ONG5TjeW9JQoDOWtFIfro/VzsyiZm1K9/syTw8mutWEqK7d2bgGoBH5/8KsvebIzjrdR+I17I+auUuuVMuKvD7E5Qb35soVZX+UrrxKbdvkRgjvB/VIlNpP1QX0SskwFvl2KpMiCZ8FzPs6Vqjpubt0Pi1BY9qjiCJDvk/SZ6hfYXjBG0w6i3QEjBJDASiWBCvMOAlN/yN64Ylpk/8/2F7IXso1vxipw8nzwbHsTSIImUk6dqNQohnfcIBBh3o4+9tJMDKCM96j5JvxEJOfdzs1+h3rFtVe91VzcYAK3oankURwN+Pa6gkV7Qq0HVPVcpAqpZHBNvQJzSCISHf5O5Z3hk80veJs92WE6nBHgn9n815nO
  template:
    metadata:
      creationTimestamp: null
      name: cloudflare-api-token-secret
      namespace: infrastructure-certmanager
    type: Opaque
    EOF
}