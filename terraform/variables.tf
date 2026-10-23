variable "aws_region" {
  type        = string
  description = "Target AWS deployment region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Target environment name"
  default     = "iac-test-bench"
}

variable "db_password" {
  type        = string
  description = "Master database password provided at deployment runtime"
  sensitive   = true
  default     = null
}
