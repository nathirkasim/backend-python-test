# ------------------------------------------------------------------------------
# Insecure Security Group Configurations (IaC Vulnerability Benchmark)
# ------------------------------------------------------------------------------

resource "aws_security_group" "open_ssh_sg" {
  name        = "iac-benchmark-open-ssh"
  description = "Security group with unrestricted inbound SSH access"
  vpc_id      = "vpc-0123456789abcdef0"

  # Misconfiguration: Open SSH (port 22) from the internet (0.0.0.0/0)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound SSH from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "open_rdp_sg" {
  name        = "iac-benchmark-open-rdp"
  description = "Security group with unrestricted inbound RDP access"
  vpc_id      = "vpc-0123456789abcdef0"

  # Misconfiguration: Open RDP (port 3389) from the internet (0.0.0.0/0)
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound RDP from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "wide_open_all_traffic" {
  name        = "iac-benchmark-wide-open"
  description = "Security group with completely open inbound traffic on all ports"
  vpc_id      = "vpc-0123456789abcdef0"

  # Misconfiguration: Completely open ingress on all ports and protocols
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
