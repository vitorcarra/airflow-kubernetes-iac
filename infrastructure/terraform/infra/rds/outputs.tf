output "rds_host" {
    value = aws_db_instance.airflow.address
}

output "rds_username" {
    value = aws_db_instance.airflow.username
}

output "rds_password" {
    value = aws_db_instance.airflow.password
}

output "rds_dbname" {
    value = aws_db_instance.airflow.name
}