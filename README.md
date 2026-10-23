# Infrastructure-as-Code (IaC) Security Benchmark Repository

> **Strict Benchmark Policy:**  
> **STRICTLY 0 SAST &bull; STRICTLY 0 SECRETS &bull; STRICTLY 0 SCA &bull; ONLY IAC**

This repository is an evaluation and benchmarking test suite designed specifically for **Infrastructure-as-Code (IaC) security scanners** (e.g., Trivy, Checkov, tfsec, KICS, Terrascan, TigerGate).

All existing application code, legacy dependencies, and secret fixtures have been completely removed. The repository contains **only intentional IaC misconfigurations** across multiple configuration formats, while rigorously maintaining **zero** findings for Static Application Security Testing (SAST), Secret scanning, and Software Composition Analysis (SCA).

---

## Modality Verification Summary

| Security Modality | Expected Findings | Actual Findings | Verification Method |
| :--- | :---: | :---: | :--- |
| **SAST** (Static Application Security Testing) | **0** | **0** | Pure IaC templates; zero vulnerable application source code files |
| **SECRETS** (Hardcoded Credentials) | **0** | **0** | No API keys, passwords, private keys, or credentials in any file |
| **SCA** (Software Composition Analysis) | **0** | **0** | No vulnerable third-party package dependencies or manifests |
| **IAC** (Infrastructure as Code) | **> 0** | **93** | Intentional cloud and container misconfigurations |

---

## Repository Structure

```text
.
├── Dockerfile                         # Container image misconfigurations (root, healthcheck, latest tag)
├── cloudformation/                    # AWS CloudFormation templates
│   ├── s3-public.yaml                 # Publicly readable unencrypted S3 bucket
│   └── security-group-open.yaml       # Unrestricted SSH/RDP ingress (0.0.0.0/0)
├── fixtures/                          # Machine-readable test fixtures
│   └── expected-iac-findings.json     # Comprehensive catalog of expected findings & rules
├── kubernetes/                        # Kubernetes workload manifests
│   ├── insecure-deployment.yaml       # Deployment lacking securityContext and resource limits
│   ├── privileged-pod.yaml            # Privileged pod, host namespaces, root mount, capabilities
│   └── rbac-insecure.yaml             # Wildcard RBAC ClusterRole permissions
├── scripts/                           # Test and verification automation
│   └── verify-scans.sh                # Automated scanner assertion script
└── terraform/                         # HashiCorp Terraform AWS configurations
    ├── cloudtrail.tf                  # Missing multi-region, validation, and KMS encryption
    ├── ec2_ebs.tf                     # IMDSv1 allowed, public IP, unencrypted EBS volumes
    ├── iam.tf                         # Wildcard admin policy (*) and wildcard assume role
    ├── main.tf                        # Provider and backend configuration
    ├── rds.tf                         # Public RDS, unencrypted storage, no backups (0 secrets)
    ├── s3.tf                          # Public read ACL, disabled public access block, no versioning
    ├── security_groups.tf             # 0.0.0.0/0 ingress on port 22 (SSH), port 3389 (RDP), all traffic
    └── variables.tf                   # Dynamic variables without default secret values
```

---

## Detailed IaC Vulnerability Catalog

### 1. Terraform (AWS)
- **S3 Bucket (`terraform/s3.tf`)**:
  - `aws_s3_bucket_acl`: Public read ACL (`public-read`)
  - `aws_s3_bucket_public_access_block`: Public access block disabled
  - `aws_s3_bucket_versioning`: Bucket versioning suspended
  - `aws_s3_bucket`: Server-side encryption (SSE-KMS/AES256) omitted
  - `aws_s3_bucket_policy`: Wildcard principal (`*`) granting public `s3:GetObject`
- **Security Groups (`terraform/security_groups.tf`)**:
  - Unrestricted inbound SSH (port 22) from `0.0.0.0/0`
  - Unrestricted inbound RDP (port 3389) from `0.0.0.0/0`
  - Wide-open ingress allowing all protocols and ports from `0.0.0.0/0`
  - Rules missing audit descriptions
- **EC2 & EBS (`terraform/ec2_ebs.tf`)**:
  - `aws_instance`: IMDSv2 not enforced (`http_tokens = "optional"`, IMDSv1 allowed)
  - `aws_instance`: Public IP association enabled (`associate_public_ip_address = true`)
  - `aws_instance`: Root block device storage unencrypted
  - `aws_ebs_volume`: Standalone EBS volume unencrypted
- **Relational Database Service (`terraform/rds.tf`)**:
  - `aws_db_instance`: Publicly accessible (`publicly_accessible = true`)
  - `aws_db_instance`: Storage encryption disabled (`storage_encrypted = false`)
  - `aws_db_instance`: Automated backups disabled (`backup_retention_period = 0`)
  - `aws_db_instance`: Multi-AZ redundancy disabled (`multi_az = false`)
  - `aws_db_instance`: Auto minor version upgrades disabled
  - *Zero Secrets Guarantee:* Database credentials are parameterized using `var.db_password` without default values, ensuring 0 secret scanner false positives.
- **Identity & Access Management (`terraform/iam.tf`)**:
  - `aws_iam_policy`: Full wildcard administrative privileges (`Action: "*"` on `Resource: "*"`)
  - `aws_iam_role`: Wildcard assume-role trust policy (`Principal: { AWS: "*" }`)
- **CloudTrail (`terraform/cloudtrail.tf`)**:
  - Log file validation disabled
  - Multi-region trail disabled
  - KMS encryption omitted

### 2. Kubernetes Manifests
- **Privileged Pod (`kubernetes/privileged-pod.yaml`)**:
  - Container executed in privileged mode (`privileged: true`)
  - Runs as root user (`runAsUser: 0`, `runAsNonRoot: false`)
  - Host namespace sharing (`hostNetwork: true`, `hostPID: true`, `hostIPC: true`)
  - Privilege escalation allowed (`allowPrivilegeEscalation: true`)
  - Insecure Linux capabilities added (`SYS_ADMIN`, `NET_ADMIN`, `ALL`)
  - Host root directory volume mount (`hostPath: /`)
  - Auto-mounting default ServiceAccount API token
  - Writable root filesystem (`readOnlyRootFilesystem: false`)
  - Missing CPU and Memory resource requests and limits
- **Insecure Deployment (`kubernetes/insecure-deployment.yaml`)**:
  - Container missing `securityContext` specification
  - Missing resource limits and requests
  - Missing liveness and readiness health probes
- **Insecure RBAC (`kubernetes/rbac-insecure.yaml`)**:
  - `ClusterRole` granting wildcard verbs (`*`) across all API groups and resources (`*`)
  - Bound directly to the `default` service account

### 3. AWS CloudFormation
- **Insecure S3 (`cloudformation/s3-public.yaml`)**:
  - `AWS::S3::Bucket` with `AccessControl: PublicRead`
  - Explicitly disabled PublicAccessBlockConfiguration
  - Missing BucketEncryption and VersioningConfiguration
- **Insecure Security Group (`cloudformation/security-group-open.yaml`)**:
  - Unrestricted ingress on port 22 (SSH) and port 3389 (RDP) from `0.0.0.0/0`

### 4. Containerfile / Dockerfile
- **Container Build Specification (`Dockerfile`)**:
  - Base image uses unpinned `:latest` tag
  - Runs as default root user (no `USER` directive)
  - Missing container `HEALTHCHECK` directive
  - Unnecessarily exposes SSH port 22

---

## Running Verification

### Automated Assertion Script
Run the automated verification script to validate all 4 criteria:

```bash
./scripts/verify-scans.sh
```

### Manual Scans with Trivy

```bash
# 1. Verify 0 Secrets
trivy fs . --scanners secret

# 2. Verify 0 SCA Vulnerabilities
trivy fs . --scanners vuln

# 3. Scan ONLY IaC Misconfigurations
trivy fs . --scanners misconfig --table-mode summary

# 4. Combined scan displaying full breakdown
trivy fs . --scanners vuln,misconfig,secret --table-mode summary
```

---

## Compliance and Policy Assurance

This repository strictly complies with automated compliance validation pipelines:
- **0 SAST**: No application source files or untrusted executable code blocks.
- **0 SECRETS**: No regex matches for high-entropy tokens, passwords, private keys, or cloud access keys.
- **0 SCA**: No vulnerable manifest dependencies (no composer, npm, pip, go, or maven manifests).
- **100% IaC**: All findings belong strictly to Infrastructure-as-Code misconfigurations.
