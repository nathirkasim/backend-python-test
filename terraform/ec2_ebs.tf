# ------------------------------------------------------------------------------
# Insecure EC2 and EBS Configurations (IaC Vulnerability Benchmark)
# ------------------------------------------------------------------------------

resource "aws_instance" "insecure_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  # Misconfiguration: Associate public IP address
  associate_public_ip_address = true

  # Misconfiguration: Detailed monitoring disabled
  monitoring = false

  # Misconfiguration: IMDSv2 not required (allows IMDSv1)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  # Misconfiguration: Unencrypted root block device
  root_block_device {
    encrypted   = false
    volume_type = "gp2"
    volume_size = 20
  }

  tags = {
    Name = "iac-benchmark-insecure-ec2"
  }
}

# Misconfiguration: Standalone EBS volume without encryption
resource "aws_ebs_volume" "unencrypted_ebs" {
  availability_zone = "us-east-1a"
  size              = 50
  encrypted         = false

  tags = {
    Name = "iac-benchmark-unencrypted-ebs"
  }
}
