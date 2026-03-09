output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = helm_release.argocd.namespace
}

output "argocd_release_name" {
  description = "Helm release name for ArgoCD"
  value       = helm_release.argocd.name
}

output "argocd_chart_version" {
  description = "Deployed ArgoCD Helm chart version"
  value       = helm_release.argocd.version
}
