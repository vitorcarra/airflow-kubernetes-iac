variable "eks_cluster_name" {
    type = string
    description = "EKS cluster name"
    default = "eks-cluster-dep"
}

variable "vpc" {}
variable "airflowdb_username" {}
variable "airflowdb_password" {}
variable "airflowdb_host" {}
variable "airflowdb_dbname" {}