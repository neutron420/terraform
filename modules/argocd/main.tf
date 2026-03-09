resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = var.namespace
  create_namespace = true
  version          = var.chart_version

  set {
    name  = "server.service.type"
    value = var.service_type
  }

  set {
    name  = "configs.params.server\\.insecure"
    value = tostring(var.server_insecure)
  }
}
