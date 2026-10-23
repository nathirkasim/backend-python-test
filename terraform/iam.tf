# ------------------------------------------------------------------------------
# Insecure IAM Policy and Role Configurations (IaC Vulnerability Benchmark)
# ------------------------------------------------------------------------------

# Misconfiguration: IAM Policy with full wildcard privileges
resource "aws_iam_policy" "wildcard_admin_policy" {
  name        = "iac-benchmark-wildcard-admin-policy"
  description = "Excessively permissive policy with full administrative actions and resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAllActionsAndResources"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

# Misconfiguration: IAM Role with wildcard assume role policy
resource "aws_iam_role" "insecure_role" {
  name = "iac-benchmark-insecure-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
