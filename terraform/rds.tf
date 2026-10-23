# ------------------------------------------------------------------------------
# Insecure RDS Database Configuration (IaC Vulnerability Benchmark)
# ------------------------------------------------------------------------------

resource "aws_db_instance" "insecure_db" {
  identifier        = "iac-benchmark-insecure-rds"
  allocated_storage = 20
  engine            = "postgres"
  engine_version    = "15.3"
  instance_class    = "db.t3.micro"
  username          = "dbadmin"

  # Master password passed securely as sensitive variable (NO hardcoded secrets)
  password = var.db_password

  # Misconfiguration: Publicly accessible database instance
  publicly_accessible = true

  # Misconfiguration: Storage encryption disabled
  storage_encrypted = false

  # Misconfiguration: Automated backups disabled
  backup_retention_period = 0

  # Misconfiguration: Multi-AZ deployment disabled
  multi_az = false

  # Misconfiguration: Auto minor version upgrades disabled
  auto_minor_version_upgrade = false

  # Misconfiguration: Deletion protection disabled
  deletion_protection = false

  # Misconfiguration: IAM database authentication disabled
  iam_database_authentication_enabled = false

  # Misconfiguration: Final snapshot skipped
  skip_final_snapshot = true
}
