variable "chart_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
  default     = "5.51.6"
}

variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "service_type" {
  description = "Service type for ArgoCD server (LoadBalancer, ClusterIP, NodePort)"
  type        = string
  default     = "LoadBalancer"
}

variable "server_insecure" {
  description = "Whether to disable TLS on the ArgoCD server (true for HTTP-only)"
  type        = bool
  default     = true
}
