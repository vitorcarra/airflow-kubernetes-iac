provider "aws" {
    region = var.aws_region
    profile = var.aws_profile
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "3.7.0"
    name = "data_plataform"
    cidr = "192.168.0.0/16"

    azs             = var.azs
    private_subnets = var.private_subnets
    public_subnets  = var.public_subnets

    enable_nat_gateway = true
    single_nat_gateway   = true
    enable_dns_hostnames = true

    tags = {
    Terraform = "true"
    Environment = "dev"
    }
}

module "eks" {
  source = "./infra/eks"

  vpc = module.vpc
  airflowdb_host = module.rds.rds_host
  airflowdb_username = module.rds.rds_username
  airflowdb_password = module.rds.rds_password
  airflowdb_dbname = module.rds.rds_dbname
}

module "ec2" {
  source = "./infra/ec2"
  vpc = module.vpc
}

module "rds" {
  source = "./infra/rds"

  vpc = module.vpc
  vpc_security_group_ids = [module.ec2.rds_security_group.id]
}

module "argocd" {
  source = "./applications/kubernetes/argocd"
  
  argocd_chart_version = "3.25.1"
  eks_module = module.eks.eks_all
}

module "kubernetes-dashboard" {
  source = "./applications/kubernetes/kubedashboard"
  eks_module = module.eks.eks_all
}