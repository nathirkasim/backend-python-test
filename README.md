# TigerGate PHP2Shell CVE Detection Test Repository

A reproducible, minimal security testing repository designed to evaluate whether **TigerGate** and container vulnerability scanners correctly detect the two critical PHP runtime vulnerabilities disclosed in the **Datadog Security Labs** report ([PHP2Shell: Critical vulnerabilities in PHP](https://securitylabs.datadoghq.com/articles/php2shell-critical-vulnerabilities-in-php/)).

> [!IMPORTANT]
> **Safety & Scope:** This is strictly an isolated **defensive test fixture** for vulnerability scanner evaluation and finding verification. It contains **no exploit payloads**, **no shell execution**, **no malicious request handling**, **no memory exhaustion tests**, and **no real credentials or secrets**.

---

## 1. Vulnerability Identifiers & Source of Truth

On October 21, 2026, the PHP group and Datadog Security Labs published security advisories for two critical remote code execution (RCE) flaws in the PHP core engine:

| Identifier | Upstream Advisory | CVSS v4.0 | Severity | Flaw Type | Core Vulnerability Mechanism |
|---|---|---|---|---|---|
| **CVE-2026-109618** | [GHSA-w8hw-w9fx-j79w](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w) | **9.2** | Critical | Memory Corruption / RCE | Interrupted initialization after memory exhaustion during hash table insertion (`_zend_hash_str_add_or_update_i`). Incomplete buckets are visited during request cleanup. |
| **CVE-2026-109619** | [GHSA-6wmf-4rv5-p3rp](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp) | **9.2** | Critical | Use-After-Free / RCE | Stale state crosses request boundaries via fatal-error backtraces (PHP 8.5) and upload progress tracking (`session.upload_progress.enabled`). |

---

## 2. Affected vs. Fixed Version Matrix

According to the official PHP security release announcements:

| PHP Branch | Affected / Vulnerable Releases | First Fixed Release |
|---|---|---|
| **PHP 8.2** | Prior to 8.2.35 | `8.2.35` |
| **PHP 8.3** | Prior to 8.3.36 | `8.3.36` |
| **PHP 8.4** | Prior to 8.4.27 | `8.4.27` |
| **PHP 8.5** | Prior to 8.5.12 | `8.5.12` |
| **PHP 7.4 / 8.0 / 8.1** | All unpatched upstream releases | Source backports published |

### Selected Test Configuration: PHP 8.3.35 vs. PHP 8.3.36

This test repository implements explicit container targets within the **PHP 8.3** series:
- **Test Target A (Vulnerable):** `PHP 8.3.35` (defined in [`Dockerfile.vulnerable`](Dockerfile.vulnerable) using `php:8.3.35-cli-alpine`)
- **Test Target B (Patched Control):** `PHP 8.3.36` (defined in [`Dockerfile.patched`](Dockerfile.patched) using `php:8.3.36-cli-alpine`)

**Why this pair was chosen:**
1. **Direct Patch Boundary:** Testing adjacent minor patch releases (`8.3.35` vs `8.3.36`) ensures differences in scan results are strictly attributable to the CVE security patches, eliminating version skew or feature divergence.
2. **Definitive False-Positive Control:** Scanning `8.3.36` provides an exact control baseline to verify that the scanner does not falsely flag fixed releases.

---

## 3. Repository Structure

```
.
├── README.md                          # Documentation, detection guide & results matrix
├── Dockerfile.vulnerable              # Pinned vulnerable PHP 8.3.35 container definition
├── Dockerfile.patched                 # Pinned patched PHP 8.3.36 control container definition
├── docker-compose.yml                 # Multi-service compose setup for both targets
├── composer.json                      # Valid PHP project manifest (no fabricated packages)
├── .gitignore                         # Excludes vendor, logs, and scan results
├── .dockerignore                      # Minimizes build context
├── src/
│   └── index.php                      # Harmless, safe JSON status endpoint
├── fixtures/
│   ├── expected-findings.json         # Structured CVE specifications and detection criteria
│   └── test-matrix.json               # Full evaluation matrix schema
└── scripts/
    ├── verify.sh                      # Local environment & repository integrity validator
    └── scan-local.sh                  # Safe local container build & scan workflow script
```

---

## 4. Repository SCA Test & TigerGate Analysis

### Can TigerGate or Traditional SCA Detect These CVEs via Repository Scanning?

1. **Vulnerability Location:**  
   `CVE-2026-109618` and `CVE-2026-109619` reside in `php-src` (the compiled C interpreter binary), **not** in a Composer package or third-party PHP library.
2. **Repository Manifest (`composer.json`) Limitations:**  
   In `composer.json`, applications declare platform version constraints (e.g. `"php": ">=8.2.0"` or `"^8.3"`). A manifest constraint only specifies language compatibility; it does not install or define the deployed PHP patch version (`8.3.35` vs `8.3.36`).
   - *Fabricating fake Composer packages to represent core PHP CVEs is strictly avoided.*
3. **Scanner Coverage Limitation:**  
   If TigerGate or any SCA tool only inspects language package manifests (`composer.json`), it will report **Inconclusive / Out of Scope** for PHP core vulnerabilities.
4. **When SCA Can Detect:**  
   If TigerGate or a combined SCA engine parses the `Dockerfile.*` base image (`FROM php:8.3.35-cli-alpine`), it can detect the vulnerable runtime from container metadata.

---

## 5. TigerGate Workflow & Architecture

Inspection of the installed `/usr/local/bin/tigergate-agent` (version 1.1.2) shows:
- **Agent Nature:** `tigergate-agent` is an endpoint/infrastructure telemetry agent. It discovers enrolled git repositories and host OS packages, transmitting inventory to the TigerGate platform console for policy and vulnerability evaluation.
- **CLI Options:** The agent provides `tigergate-agent scan`, `status`, `checkin`, and `configure`. It does **not** feature an offline standalone container image scanner CLI subcommand.
- **Container Workflow:** To scan container images with TigerGate:
  1. Enrol the container pipeline or CI runner with TigerGate infrastructure profile (`--infra`), or
  2. Use a supported container image scanning integration (or supplementary container engines like Trivy/Grype) to inspect the built images and review findings in the TigerGate console.

---

## 6. Container Image Testing Guide

### Step 1: Run Repository Integrity Verification
```bash
./scripts/verify.sh
```

### Step 2: Build the Container Images
```bash
# Build vulnerable target image
docker build -f Dockerfile.vulnerable -t php2shell-security-test:vulnerable .

# Build patched control image
docker build -f Dockerfile.patched -t php2shell-security-test:patched .
```

### Step 3: Inspect Container Runtime Versions Safely
Verify the runtime version inside each image without executing any exploit:
```bash
# Inspect vulnerable target
docker run --rm php2shell-security-test:vulnerable php -v

# Inspect patched target
docker run --rm php2shell-security-test:patched php -v
```

### Step 4: Run the Complete Local Workflow
Execute [`scripts/scan-local.sh`](scripts/scan-local.sh) to build both images, query TigerGate agent telemetry, and save outputs:
```bash
./scripts/scan-local.sh
```

---

## 7. Expected Results Matrix

| Test Scenario | Evaluated Target | Expected Result | Technical Verification Criteria |
|---|---|---|---|
| **Affected PHP runtime** | `php2shell-security-test:vulnerable` (PHP 8.3.35) | **Both CVEs should be reported if supported by the scanner and advisory database** | Both `CVE-2026-109618` and `CVE-2026-109619` flagged as Critical severity. |
| **Patched PHP runtime** | `php2shell-security-test:patched` (PHP 8.3.36) | **Neither CVE should be reported as affecting that runtime** | Clean scan. Any finding represents a false positive in the scanner's version comparator. |
| **Repository-only SCA** | `composer.json` / Repository root | **Depends on whether the PHP runtime is discoverable** | Inconclusive if only scanning Composer packages. Detected only if scanner parses Dockerfile base images. |
| **Container scanning** | Container layers & OS packages | **Depends on image inventory and CVE coverage** | Alpine OS packages / PHP binary inspected; flags vulnerable release. |
| **No findings diagnostic** | Zero findings on vulnerable image | **Investigate coverage, inventory, and advisory freshness before concluding** | Never mark a test as passed merely because the scan command completed successfully without errors. |

---

## 8. Cleanup

To remove local test containers and built images:
```bash
docker compose down --volumes --rmi local
docker rmi php2shell-security-test:vulnerable php2shell-security-test:patched 2>/dev/null || true
```

---

## 9. References

- [Datadog Security Labs: PHP2Shell - Critical vulnerabilities in PHP](https://securitylabs.datadoghq.com/articles/php2shell-critical-vulnerabilities-in-php/)
- [PHP Security Advisory: GHSA-w8hw-w9fx-j79w (CVE-2026-109618)](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w)
- [PHP Security Advisory: GHSA-6wmf-4rv5-p3rp (CVE-2026-109619)](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp)
- [PHP Official Security Announcement](https://www.php.net/archive/2026.php#2026-10-21-1)
