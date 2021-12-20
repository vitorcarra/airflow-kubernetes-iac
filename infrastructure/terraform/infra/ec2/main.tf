resource "aws_security_group" "rds_sg" {
  name        = "airflow-postgres-sg"
  vpc_id      = local.vpc.vpc_id

  ingress {
    description = "Enable postgres access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


locals {
  vpc = var.vpc
}