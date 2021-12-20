resource "aws_db_subnet_group" "default" {
  name       = "vpc-subnet-group-airflow"
  subnet_ids = local.vpc.private_subnets
}

resource "random_password" "password" {
  length           = 16
  special          = false
}

resource "aws_db_instance" "airflow" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "13.3"
  instance_class          = "db.t3.micro"
  name                    = "airflow_db"
  username                = "airflow_admin"
  password                = random_password.password.result
  parameter_group_name    = "default.postgres13"
  identifier              = "airflow-postgres"
  port                    = 5432
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.default.name
  skip_final_snapshot    = true
}

locals {
  vpc = var.vpc
}