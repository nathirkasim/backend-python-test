#!/usr/bin/env bash
# ==============================================================================
# TigerGate PHP2Shell Test Repository Integrity and Verification Script
#
# CHECKS PERFORMED:
# 1. Required repository files exist (README, Dockerfiles, compose, fixtures, scripts).
# 2. Docker is available on the host environment.
# 3. PHP runtime versions are configured and distinct between vulnerable & patched.
# 4. Expected CVE identifiers (CVE-2026-109618, CVE-2026-109619) are documented.
# 5. TigerGate agent status is checked (if installed).
#
# CRITICAL RULE:
# This script does NOT claim TigerGate or any scanner detected a CVE without
# actual scan output. It validates test fixture and configuration readiness.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}     TigerGate PHP2Shell CVE Detection Test: Verifier           ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""

ERRORS=0

check_file() {
    local file_path="$1"
    local relative_path="${file_path#$REPO_ROOT/}"
    if [[ -f "$file_path" ]]; then
        echo -e "  [${GREEN}✓${NC}] File present: ${relative_path}"
    else
        echo -e "  [${RED}✗${NC}] Missing file: ${relative_path}"
        ERRORS=$((ERRORS + 1))
    fi
}

validate_json() {
    local json_file="$1"
    local relative_path="${json_file#$REPO_ROOT/}"
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$json_file" >/dev/null 2>&1; then
            echo -e "  [${GREEN}✓${NC}] Valid JSON: ${relative_path}"
        else
            echo -e "  [${RED}✗${NC}] Invalid JSON: ${relative_path}"
            ERRORS=$((ERRORS + 1))
        fi
    elif command -v python3 >/dev/null 2>&1; then
        if python3 -m json.tool "$json_file" >/dev/null 2>&1; then
            echo -e "  [${GREEN}✓${NC}] Valid JSON (python3): ${relative_path}"
        else
            echo -e "  [${RED}✗${NC}] Invalid JSON (python3): ${relative_path}"
            ERRORS=$((ERRORS + 1))
        fi
    fi
}

echo -e "${CYAN}1. Verifying repository file structure...${NC}"
check_file "${REPO_ROOT}/README.md"
check_file "${REPO_ROOT}/Dockerfile.vulnerable"
check_file "${REPO_ROOT}/Dockerfile.patched"
check_file "${REPO_ROOT}/docker-compose.yml"
check_file "${REPO_ROOT}/composer.json"
check_file "${REPO_ROOT}/src/index.php"
check_file "${REPO_ROOT}/fixtures/expected-findings.json"
check_file "${REPO_ROOT}/fixtures/test-matrix.json"
check_file "${REPO_ROOT}/scripts/verify.sh"
check_file "${REPO_ROOT}/scripts/scan-local.sh"
echo ""

echo -e "${CYAN}2. Validating JSON configuration and metadata files...${NC}"
validate_json "${REPO_ROOT}/composer.json"
validate_json "${REPO_ROOT}/fixtures/expected-findings.json"
validate_json "${REPO_ROOT}/fixtures/test-matrix.json"
echo ""

echo -e "${CYAN}3. Inspecting configured PHP runtime versions...${NC}"
VULN_PHP=$(grep -E "^FROM " "${REPO_ROOT}/Dockerfile.vulnerable" | awk '{print $2}' || echo "Not found")
PATCH_PHP=$(grep -E "^FROM " "${REPO_ROOT}/Dockerfile.patched" | awk '{print $2}' || echo "Not found")

echo -e "  - Vulnerable configuration: ${YELLOW}${VULN_PHP}${NC}"
echo -e "  - Patched configuration:    ${YELLOW}${PATCH_PHP}${NC}"

if [[ "$VULN_PHP" != "$PATCH_PHP" && "$VULN_PHP" != "Not found" && "$PATCH_PHP" != "Not found" ]]; then
    echo -e "  [${GREEN}✓${NC}] Distinct runtime configurations confirmed between vulnerable and patched test targets."
else
    echo -e "  [${RED}✗${NC}] Vulnerable and patched configurations must use distinct versions."
    ERRORS=$((ERRORS + 1))
fi
echo ""

echo -e "${CYAN}4. Checking documented CVE identifiers...${NC}"
for cve in "CVE-2026-109618" "CVE-2026-109619"; do
    if grep -q "$cve" "${REPO_ROOT}/README.md" && \
       grep -q "$cve" "${REPO_ROOT}/fixtures/expected-findings.json" && \
       grep -q "$cve" "${REPO_ROOT}/fixtures/test-matrix.json"; then
        echo -e "  [${GREEN}✓${NC}] ${cve} documented across README.md and fixtures"
    else
        echo -e "  [${RED}✗${NC}] ${cve} missing in documentation or fixtures"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

echo -e "${CYAN}5. Inspecting Docker environment...${NC}"
if command -v docker >/dev/null 2>&1; then
    echo -e "  [${GREEN}✓${NC}] Docker installed: $(docker --version)"
else
    echo -e "  [${RED}✗${NC}] Docker is not installed on this host"
    ERRORS=$((ERRORS + 1))
fi

if docker compose version >/dev/null 2>&1; then
    echo -e "  [${GREEN}✓${NC}] Docker Compose installed: $(docker compose version)"
else
    echo -e "  [${YELLOW}!${NC}] Docker Compose not detected"
fi
echo ""

echo -e "${CYAN}6. Checking TigerGate scanner status...${NC}"
if command -v tigergate-agent >/dev/null 2>&1; then
    echo -e "  [${GREEN}✓${NC}] tigergate-agent detected: $(tigergate-agent version 2>/dev/null || which tigergate-agent)"
    echo -e "      (Agent enrollment & telemetry mode. See scripts/scan-local.sh for scan workflow)"
else
    echo -e "  [${YELLOW}!${NC}] tigergate-agent CLI not found in PATH"
fi
echo ""

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}                     Configuration Summary                      ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "  Vulnerable Target:   ${VULN_PHP}"
echo -e "  Patched Target:      ${PATCH_PHP}"
echo -e "  Target CVEs:         CVE-2026-109618, CVE-2026-109619"
echo -e "  Repository SCA:      composer.json manifest present (runtime out of scope)"
echo -e "  Container Testing:   Dockerfile.vulnerable & Dockerfile.patched ready"
echo -e "${BLUE}----------------------------------------------------------------${NC}"

if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}✓ Verification completed with 0 errors. Repository is ready.${NC}"
    exit 0
else
    echo -e "${RED}✗ Verification encountered ${ERRORS} error(s). Please fix before scanning.${NC}"
    exit 1
fi
