#!/bin/bash
# halcyon-api-install.sh
# Installs the Halcyon Linux agent by authenticating to the Halcyon API,
# retrieving the current installer and install token for the target tenant,
# downloading the tarball, and running the standard install.sh.
#
# Author  : Jim Harris -- Halcyon SA
# Version : v1.0
#
# Usage:
#   HAL_USER='user@example.com' HAL_PASS='yourpassword' HAL_TENANT='<tenant-uuid>' bash halcyon-api-install.sh
#
#   Or run interactively (will prompt for missing values):
#   bash halcyon-api-install.sh
#
# Requirements:
#   curl, python3, tar (all standard on supported Halcyon Linux distros)
#
# Security note:
#   Passing HAL_PASS inline on the command line will expose the password in
#   shell history and the process list. For automation, prefer setting it
#   via a secrets manager or an environment file sourced before running this
#   script. The interactive prompt (no HAL_PASS set) avoids both risks.

set -e

HAL_API="https://api.halcyon.ai"

# ------------------------------------------------------------------ #
# Colour helpers
# ------------------------------------------------------------------ #
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[halcyon]${NC} $*"; }
ok()    { echo -e "${GREEN}[ok]${NC}     $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}   $*"; }
fail()  { echo -e "${RED}[fail]${NC}   $*"; exit 1; }

# ------------------------------------------------------------------ #
# Dependency check
# ------------------------------------------------------------------ #
for cmd in curl python3 tar; do
    command -v "$cmd" >/dev/null 2>&1 || fail "Missing required command: $cmd"
done

# ------------------------------------------------------------------ #
# Credential resolution -- env vars or interactive prompt
# ------------------------------------------------------------------ #
echo ""
echo "  Halcyon API Installer"
echo "  ====================="
echo ""

if [ -z "$HAL_USER" ]; then
    printf "  Halcyon login email   : "
    read -r HAL_USER
fi

if [ -z "$HAL_PASS" ]; then
    printf "  Halcyon password      : "
    read -rs HAL_PASS
    echo ""
fi

if [ -z "$HAL_TENANT" ]; then
    printf "  Tenant ID (UUID)      : "
    read -r HAL_TENANT
fi

echo ""

# Basic UUID format check
if ! echo "$HAL_TENANT" | grep -qE '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'; then
    fail "HAL_TENANT does not look like a valid UUID: $HAL_TENANT"
fi

# ------------------------------------------------------------------ #
# Step 1: Authenticate
# ------------------------------------------------------------------ #
info "Step 1/5: Authenticating as $HAL_USER against tenant $HAL_TENANT ..."

AUTH_PAYLOAD="{\"username\":\"${HAL_USER}\",\"password\":\"${HAL_PASS}\"}"

AUTH_RESPONSE=$(curl -fsSL \
    -X POST "$HAL_API/identity/auth/login" \
    -H "Content-Type: application/json" \
    -H "X-TenantID: $HAL_TENANT" \
    -d "$AUTH_PAYLOAD") || fail "Authentication request failed. Check network connectivity to $HAL_API"

# Clear password from memory as early as possible
unset HAL_PASS
unset AUTH_PAYLOAD

ACCESS_TOKEN=$(echo "$AUTH_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    token = data.get('accessToken', '')
    if token:
        print(token)
    else:
        sys.exit(1)
except Exception:
    sys.exit(1)
") || fail "Authentication failed. Check credentials and confirm the tenant ID is correct."

unset AUTH_RESPONSE

ok "Authenticated successfully."

# ------------------------------------------------------------------ #
# Step 2: Fetch installer info
# ------------------------------------------------------------------ #
info "Step 2/5: Fetching Linux installer info from tenant ..."

INSTALLERS=$(curl -fsSL \
    "$HAL_API/v2/installers?pageSize=50" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "X-TenantID: $HAL_TENANT") || fail "Failed to retrieve installer list from API."

INSTALLER_FIELDS=$(echo "$INSTALLERS" | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)
except Exception as e:
    print('PARSE_ERROR', flush=True)
    sys.exit(1)

items = data.get('data', [])
if not items:
    print('NO_DATA', flush=True)
    sys.exit(1)

linux = [i for i in items if str(i.get('installerType', '')).lower() == 'linux']
if not linux:
    print('NO_LINUX', flush=True)
    sys.exit(1)

# Prefer the entry flagged as latest version
latest = next((i for i in linux if i.get('latestVersion') == i.get('version')), linux[0])

url   = latest.get('downloadUrl', '')
token = latest.get('installationToken', '')
ver   = latest.get('version', 'unknown')

if not url or not token:
    print('MISSING_FIELDS', flush=True)
    sys.exit(1)

print(url)
print(token)
print(ver)
") || true

case "$INSTALLER_FIELDS" in
    PARSE_ERROR)  fail "Could not parse API response. Unexpected format." ;;
    NO_DATA)      fail "API returned no installers. Check tenant configuration." ;;
    NO_LINUX)     fail "No Linux installer found. Confirm the Linux add-on is enabled on this tenant." ;;
    MISSING_FIELDS) fail "Installer entry is missing downloadUrl or installationToken." ;;
esac

DOWNLOAD_URL=$(echo "$INSTALLER_FIELDS"  | sed -n '1p')
INSTALL_TOKEN=$(echo "$INSTALLER_FIELDS" | sed -n '2p')
AGENT_VERSION=$(echo "$INSTALLER_FIELDS" | sed -n '3p')

ok "Linux installer found: v${AGENT_VERSION}"
info "  Download URL   : $DOWNLOAD_URL"
info "  Install token  : ${INSTALL_TOKEN:0:8}****************  (truncated for display)"

# ------------------------------------------------------------------ #
# Step 3: Download
# ------------------------------------------------------------------ #
info "Step 3/5: Downloading installer tarball ..."

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

curl -fsSL --progress-bar -o "$WORK_DIR/halcyonar.tar.gz" "$DOWNLOAD_URL" \
    || fail "Download failed. Check outbound HTTPS access to the download host."

ok "Download complete."

# ------------------------------------------------------------------ #
# Step 4: Extract
# ------------------------------------------------------------------ #
info "Step 4/5: Extracting tarball ..."

tar xzf "$WORK_DIR/halcyonar.tar.gz" -C "$WORK_DIR" \
    || fail "Extraction failed."

# Locate install.sh -- it may be at root or one level deep
INSTALL_SH=$(find "$WORK_DIR" -name "install.sh" | head -1)
[ -n "$INSTALL_SH" ] || fail "install.sh not found in tarball."

ok "Extracted to $WORK_DIR"

# ------------------------------------------------------------------ #
# Step 5: Install
# ------------------------------------------------------------------ #
info "Step 5/5: Running installer ..."
echo ""

cd "$(dirname "$INSTALL_SH")"
HALCYON_TOKEN="$INSTALL_TOKEN" bash install.sh

# Clear token
unset INSTALL_TOKEN

echo ""
ok "Halcyon agent installation complete."
info "Check the Halcyon console to confirm this device appears in Assets."
echo ""