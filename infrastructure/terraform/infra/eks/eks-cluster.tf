module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.21"

  vpc_id          = local.vpc.vpc_id
  subnets         = [local.vpc.private_subnets[0], local.vpc.public_subnets[1]]
  fargate_subnets = [local.vpc.private_subnets[2]]

  cluster_log_retention_in_days = 3

  cluster_endpoint_public_access  = true

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]

  worker_groups = [
    {
      name = "worker-group-1"
      instance_type = "t3.small"
      asg_desired_capacity = 2
      asg_max_size  = 5
      platform = "linux"
    }
  ]

  tags = {
    Environment = "dev"
    Name = "eks-dep-cluster"
  }
}

resource "kubernetes_service_account" "eksadmin" {
  metadata {
    name = "eks-admin"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "eksadmin" {
  metadata {
    name = "eks-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "eks-admin"
    namespace = "kube-system"
  }
}

resource "kubernetes_namespace" "airflow" {
  metadata {
    name = "airflow"
  }
}

resource "kubernetes_secret" "airflow_db_credentials" {
  metadata {
    name = "airflow-db-auth"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }

  data = {
    "postgresql-password" = "${var.airflowdb_password}"
  }
}

#############
# Kubernetes
#############

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

locals {
  vpc = var.vpc
}



resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = local.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}