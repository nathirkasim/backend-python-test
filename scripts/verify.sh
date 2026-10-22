#!/usr/bin/env bash
# ==============================================================================
# PHP2Shell Test Repository Integrity and Configuration Verification Script
#
# PURPOSE:
# Performs harmless local checks to verify that repository structure, JSON
# metadata, CVE references, and Docker configurations are intact and valid.
#
# NOTE:
# This script does NOT execute exploits, does not make malicious requests,
# and does NOT simulate or declare a scanner finding. Actual vulnerability
# detection requires running your security scanner against the artifacts.
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
echo -e "${BLUE}  PHP2Shell Vulnerability Detection Test: Integrity Verifier   ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""

ERRORS=0

# Helper function to validate file existence
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

# Helper function to validate JSON syntax
validate_json() {
    local json_file="$1"
    local relative_path="${json_file#$REPO_ROOT/}"
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$json_file" >/dev/null 2>&1; then
            echo -e "  [${GREEN}✓${NC}] Valid JSON syntax: ${relative_path}"
        else
            echo -e "  [${RED}✗${NC}] Invalid JSON syntax: ${relative_path}"
            ERRORS=$((ERRORS + 1))
        fi
    elif command -v python3 >/dev/null 2>&1; then
        if python3 -m json.tool "$json_file" >/dev/null 2>&1; then
            echo -e "  [${GREEN}✓${NC}] Valid JSON syntax (python3): ${relative_path}"
        else
            echo -e "  [${RED}✗${NC}] Invalid JSON syntax (python3): ${relative_path}"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "  [${YELLOW}!${NC}] Neither jq nor python3 found; skipping JSON syntax check for ${relative_path}"
    fi
}

echo -e "${CYAN}1. Verifying repository file structure...${NC}"
check_file "${REPO_ROOT}/README.md"
check_file "${REPO_ROOT}/Dockerfile"
check_file "${REPO_ROOT}/docker-compose.yml"
check_file "${REPO_ROOT}/composer.json"
check_file "${REPO_ROOT}/.gitignore"
check_file "${REPO_ROOT}/.dockerignore"
check_file "${REPO_ROOT}/src/index.php"
check_file "${REPO_ROOT}/fixtures/vulnerable-runtime.json"
check_file "${REPO_ROOT}/fixtures/patched-runtime.json"
check_file "${REPO_ROOT}/scripts/verify.sh"
echo ""

echo -e "${CYAN}2. Validating JSON configuration and fixture files...${NC}"
validate_json "${REPO_ROOT}/composer.json"
validate_json "${REPO_ROOT}/fixtures/vulnerable-runtime.json"
validate_json "${REPO_ROOT}/fixtures/patched-runtime.json"
echo ""

echo -e "${CYAN}3. Inspecting configured PHP runtime versions...${NC}"
DOCKERFILE_DEFAULT=$(grep -E "^ARG PHP_VERSION=" "${REPO_ROOT}/Dockerfile" | cut -d'=' -f2 || echo "Not found")
COMPOSE_VULN=$(grep -A 5 "vulnerable-runtime:" "${REPO_ROOT}/docker-compose.yml" | grep "PHP_VERSION:" | awk '{print $2}' | tr -d '"' || echo "Not found")
COMPOSE_PATCHED=$(grep -A 5 "patched-runtime:" "${REPO_ROOT}/docker-compose.yml" | grep "PHP_VERSION:" | awk '{print $2}' | tr -d '"' || echo "Not found")

echo -e "  - Dockerfile default runtime:  ${YELLOW}${DOCKERFILE_DEFAULT}${NC}"
echo -e "  - Compose vulnerable service:  ${YELLOW}${COMPOSE_VULN}${NC}"
echo -e "  - Compose patched service:     ${YELLOW}${COMPOSE_PATCHED}${NC}"
echo ""

echo -e "${CYAN}4. Checking documented CVE identifiers in fixtures and README...${NC}"
for cve in "CVE-2026-109618" "CVE-2026-109619"; do
    if grep -q "$cve" "${REPO_ROOT}/README.md"; then
        echo -e "  [${GREEN}✓${NC}] ${cve} documented in README.md"
    else
        echo -e "  [${RED}✗${NC}] ${cve} NOT found in README.md"
        ERRORS=$((ERRORS + 1))
    fi

    if grep -q "$cve" "${REPO_ROOT}/fixtures/vulnerable-runtime.json"; then
        echo -e "  [${GREEN}✓${NC}] ${cve} referenced in fixtures/vulnerable-runtime.json"
    else
        echo -e "  [${RED}✗${NC}] ${cve} NOT found in fixtures/vulnerable-runtime.json"
        ERRORS=$((ERRORS + 1))
    fi

    if grep -q "$cve" "${REPO_ROOT}/fixtures/patched-runtime.json"; then
        echo -e "  [${GREEN}✓${NC}] ${cve} referenced in fixtures/patched-runtime.json"
    else
        echo -e "  [${RED}✗${NC}] ${cve} NOT found in fixtures/patched-runtime.json"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

echo -e "${CYAN}5. Checking Docker environment prerequisites...${NC}"
if command -v docker >/dev/null 2>&1; then
    DOCKER_VER=$(docker --version)
    echo -e "  [${GREEN}✓${NC}] Docker installed: ${DOCKER_VER}"
else
    echo -e "  [${YELLOW}!${NC}] Docker not installed on host (required only if running container tests locally)"
fi

if docker compose version >/dev/null 2>&1; then
    COMPOSE_VER=$(docker compose version)
    echo -e "  [${GREEN}✓${NC}] Docker Compose installed: ${COMPOSE_VER}"
else
    echo -e "  [${YELLOW}!${NC}] Docker Compose not installed on host"
fi
echo ""

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}                    Test Configuration Summary                  ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "  Repository Name:         php2shell-security-test"
echo -e "  Primary Language:        PHP"
echo -e "  Test A (Vulnerable):     PHP 8.3.35 (Targeted for CVE-2026-109618, CVE-2026-109619)"
echo -e "  Test B (Patched):        PHP 8.3.36 (Fixed reference control case)"
echo -e "  Source Reference:        Datadog Security Labs (PHP2Shell disclosure)"
echo -e "  Detection Scope:         Container Base Image / Runtime OS Scan"
echo -e "  Repository SCA Scope:    Inconclusive for C runtime unless container aware"
echo -e "${BLUE}----------------------------------------------------------------${NC}"

if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}✓ All repository integrity checks passed successfully.${NC}"
    echo -e "Ready for security scanner validation."
    exit 0
else
    echo -e "${RED}✗ Verification encountered ${ERRORS} issue(s). Please review above.${NC}"
    exit 1
fi
