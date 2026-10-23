# Synthetic Terraform IaC Fixture for TigerGate IaC Scanning
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAC-001: S3 bucket missing encryption, access logging, and public access block
resource "aws_s3_bucket" "unsecured_bucket" {
  bucket = "tg-synthetic-iac-unsecured-bucket"
}

# IAC-002: Security Group allowing unrestricted ingress from 0.0.0.0/0 on SSH port 22
resource "aws_security_group" "open_ssh" {
  name        = "tg-synthetic-open-ssh-sg"
  description = "Synthetic insecure security group with unrestricted SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
