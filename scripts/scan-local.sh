#!/usr/bin/env bash
# ==============================================================================
# TigerGate PHP2Shell Local Container Build and Scan Workflow Script
#
# PURPOSE:
# 1. Builds both vulnerable (PHP 8.3.35) and patched (PHP 8.3.36) test images.
# 2. Safely inspects the PHP runtime versions using `php -v`.
# 3. Executes TigerGate agent inventory telemetry check.
# 4. Saves scan outputs and checks for CVE-2026-109618 and CVE-2026-109619.
#
# NOTE:
# This script executes only harmless version inspection and inventory queries.
# It does NOT execute exploits or generate malicious network traffic.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

RESULTS_DIR="${REPO_ROOT}/scan-results"
mkdir -p "${RESULTS_DIR}"

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}        PHP2Shell Local Container Build & Scanner Workflow       ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""

# Step 1: Build Container Images
echo -e "${CYAN}Step 1: Building local test images...${NC}"

echo -e "Building vulnerable target image (php2shell-security-test:vulnerable)..."
docker build -f "${REPO_ROOT}/Dockerfile.vulnerable" -t php2shell-security-test:vulnerable "${REPO_ROOT}"

echo -e "Building patched target image (php2shell-security-test:patched)..."
docker build -f "${REPO_ROOT}/Dockerfile.patched" -t php2shell-security-test:patched "${REPO_ROOT}"

echo -e "  [${GREEN}✓${NC}] Container images built successfully."
echo ""

# Step 2: Inspect PHP Runtime Versions
echo -e "${CYAN}Step 2: Inspecting container runtime versions safely (php -v)...${NC}"
echo -n "  - Vulnerable image runtime: "
docker run --rm php2shell-security-test:vulnerable php -v | head -n 1
echo -n "  - Patched image runtime:    "
docker run --rm php2shell-security-test:patched php -v | head -n 1
echo ""

# Step 3: TigerGate Agent Inspection
echo -e "${CYAN}Step 3: Checking TigerGate scanner status and telemetry...${NC}"
if command -v tigergate-agent >/dev/null 2>&1; then
    echo -e "TigerGate Agent Status:"
    tigergate-agent status || true
    echo ""
    echo -e "Running TigerGate agent local dry-run telemetry collection..."
    tigergate-agent scan --dry-run --json > "${RESULTS_DIR}/tigergate-telemetry.json" 2>&1 || true
    echo -e "  [${GREEN}✓${NC}] TigerGate telemetry saved to scan-results/tigergate-telemetry.json"
    echo ""
    echo -e "${YELLOW}TigerGate Workflow Architecture Note:${NC}"
    echo -e "  The installed 'tigergate-agent' operates as an endpoint & infrastructure"
    echo -e "  telemetry collector. It monitors enrolled git repositories and host/OS"
    echo -e "  packages, transmitting inventory to the TigerGate platform console for"
    echo -e "  policy & vulnerability assessment."
    echo -e "  The agent CLI does not have an offline direct-container image scanner."
    echo -e "  Direct container image scanning is evaluated via container pipeline"
    echo -e "  or supplementary container scanner engines."
else
    echo -e "  [${YELLOW}!${NC}] tigergate-agent is not installed in PATH."
fi
echo ""

# Step 4: Supplementary Container Scanner Execution (if available)
echo -e "${CYAN}Step 4: Executing container vulnerability scanning...${NC}"
SCANNED=0

if command -v trivy >/dev/null 2>&1; then
    echo -e "Executing Trivy scan on vulnerable image..."
    trivy image --format json --output "${RESULTS_DIR}/vulnerable-trivy.json" php2shell-security-test:vulnerable || true
    echo -e "Executing Trivy scan on patched image..."
    trivy image --format json --output "${RESULTS_DIR}/patched-trivy.json" php2shell-security-test:patched || true
    SCANNED=1
elif command -v grype >/dev/null 2>&1; then
    echo -e "Executing Grype scan on vulnerable image..."
    grype php2shell-security-test:vulnerable -o json > "${RESULTS_DIR}/vulnerable-grype.json" || true
    echo -e "Executing Grype scan on patched image..."
    grype php2shell-security-test:patched -o json > "${RESULTS_DIR}/patched-grype.json" || true
    SCANNED=1
fi

if [[ $SCANNED -eq 0 ]]; then
    echo -e "${YELLOW}Notice:${NC} Direct container CLI scanner (Trivy/Grype) not detected on host."
    echo -e "To scan container images with TigerGate or your preferred container scanner:"
    echo -e "  1. Point your container CI scanner at 'php2shell-security-test:vulnerable'"
    echo -e "  2. Save results to '${RESULTS_DIR}/vulnerable-scan.json'"
    echo -e "  3. Point scanner at 'php2shell-security-test:patched'"
    echo -e "  4. Save results to '${RESULTS_DIR}/patched-scan.json'"
fi
echo ""

# Step 5: Findings Evaluation Summary
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}                       Scan Findings Summary                     ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "Target CVEs to verify in scan output:"
echo -e "  - CVE-2026-109618 (PHP hash table memory exhaustion RCE)"
echo -e "  - CVE-2026-109619 (PHP use-after-free RCE in upload progress)"
echo ""
echo -e "Expected Comparison:"
echo -e "  - Vulnerable (8.3.35): Both CVEs flagged if scanner advisory DB is current"
echo -e "  - Patched (8.3.36):    0 findings for both CVEs (Control case)"
echo -e "${BLUE}----------------------------------------------------------------${NC}"
echo -e "Scan logs and outputs preserved in: ${RESULTS_DIR}/"
