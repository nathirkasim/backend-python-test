# ------------------------------------------------------------------------------
# Insecure S3 Bucket Definitions (IaC Vulnerability Benchmark)
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "insecure_public_bucket" {
  bucket        = "iac-benchmark-public-bucket-unencrypted"
  force_destroy = true
}

# Misconfiguration: Public read ACL
resource "aws_s3_bucket_acl" "insecure_acl" {
  bucket = aws_s3_bucket.insecure_public_bucket.id
  acl    = "public-read"
}

# Misconfiguration: Explicitly disabling Public Access Block
resource "aws_s3_bucket_public_access_block" "disabled_public_access_block" {
  bucket = aws_s3_bucket.insecure_public_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Misconfiguration: Explicitly suspended / disabled versioning
resource "aws_s3_bucket_versioning" "insecure_versioning" {
  bucket = aws_s3_bucket.insecure_public_bucket.id
  versioning_configuration {
    status = "Suspended"
  }
}

# Misconfiguration: Overly permissive public bucket policy
resource "aws_s3_bucket_policy" "insecure_policy" {
  bucket = aws_s3_bucket.insecure_public_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.insecure_public_bucket.arn}/*"
      }
    ]
  })
}
