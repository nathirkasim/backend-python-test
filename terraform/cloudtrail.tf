# ------------------------------------------------------------------------------
# Insecure AWS CloudTrail Configuration (IaC Vulnerability Benchmark)
# ------------------------------------------------------------------------------

resource "aws_cloudtrail" "insecure_trail" {
  name                          = "iac-benchmark-insecure-trail"
  s3_bucket_name                = aws_s3_bucket.insecure_public_bucket.id
  include_global_service_events = false

  # Misconfiguration: Multi-region trail disabled
  is_multi_region_trail = false

  # Misconfiguration: Log file validation disabled
  enable_log_file_validation = false

  # Misconfiguration: Missing KMS key encryption (missing kms_key_id)
  # Misconfiguration: Missing CloudWatch Logs group configuration
}
