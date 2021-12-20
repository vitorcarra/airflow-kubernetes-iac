variable "argocd_chart_version" {
  type = string
  description = "ArgoCD chart version to be installed. Default = 3.25.1"
  default = "3.25.1"
}

variable "eks_module" {}