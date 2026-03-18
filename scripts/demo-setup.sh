#!/usr/bin/env bash
set -uo pipefail

# ──────────────────────────────────────────────────────────────
# Demo Pre-Flight Validation Script
# Run from the project root directory.
# ──────────────────────────────────────────────────────────────

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BOLD="\033[1m"
RESET="\033[0m"

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

pass()  { PASS_COUNT=$((PASS_COUNT + 1));  echo -e "  ${GREEN}[PASS]${RESET} $1"; }
fail()  { FAIL_COUNT=$((FAIL_COUNT + 1));  echo -e "  ${RED}[FAIL]${RESET} $1"; }
skip()  { SKIP_COUNT=$((SKIP_COUNT + 1));  echo -e "  ${YELLOW}[SKIP]${RESET} $1"; }

GATEWAY_URL="https://192.168.1.82:8000"

echo ""
echo -e "${BOLD}=== Akeyless Secure AI Agents — Demo Pre-Flight ===${RESET}"
echo ""

# ── 1. Akeyless CLI installed & version ──────────────────────
echo -e "${BOLD}1. Akeyless CLI${RESET}"
if [[ -x /usr/bin/akeyless ]]; then
    CLI_VERSION=$(/usr/bin/akeyless --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || true)
    if [[ -n "$CLI_VERSION" ]]; then
        # Compare version >= 1.130.0
        REQUIRED="1.130.0"
        version_ge() {
            # Returns 0 (true) if $1 >= $2
            printf '%s\n%s' "$2" "$1" | sort -V | head -1 | grep -qx "$2"
        }
        if version_ge "$CLI_VERSION" "$REQUIRED"; then
            pass "akeyless CLI v${CLI_VERSION} (>= ${REQUIRED})"
        else
            fail "akeyless CLI v${CLI_VERSION} — need >= ${REQUIRED}"
        fi
    else
        fail "akeyless CLI found but could not determine version"
    fi
else
    fail "akeyless CLI not found at /usr/bin/akeyless"
fi

# ── 2. Gateway reachable ─────────────────────────────────────
echo -e "${BOLD}2. Akeyless Gateway${RESET}"
if curl -sk --max-time 5 "${GATEWAY_URL}/status" -o /dev/null 2>/dev/null; then
    pass "Gateway reachable at ${GATEWAY_URL}"
else
    fail "Gateway unreachable at ${GATEWAY_URL}"
fi

# ── 3. MySQL pod running in akeyless namespace ───────────────
echo -e "${BOLD}3. MySQL Pod${RESET}"
if command -v kubectl &>/dev/null; then
    MYSQL_POD=$(kubectl get pod -n akeyless --no-headers 2>/dev/null | grep -i mysql | grep -i running || true)
    if [[ -n "$MYSQL_POD" ]]; then
        POD_NAME=$(echo "$MYSQL_POD" | awk '{print $1}')
        pass "MySQL pod running: ${POD_NAME}"
    else
        fail "No running MySQL pod found in akeyless namespace"
    fi
else
    fail "kubectl not found — cannot check MySQL pod"
fi

# ── 4. Dynamic secret producer ───────────────────────────────
echo -e "${BOLD}4. Dynamic Secret Producer${RESET}"
if DS_OUTPUT=$(akeyless dynamic-secret get-value \
    --name /demo-ai-agents/mysql-dynamic-secret \
    --profile demo 2>&1); then
    pass "Dynamic secret producer returned credentials"
else
    fail "Dynamic secret producer failed: $(echo "$DS_OUTPUT" | head -1)"
fi

# ── 5. Universal Identity auth ───────────────────────────────
echo -e "${BOLD}5. Universal Identity Auth${RESET}"
MCP_FILE=".mcp.json"
if [[ -f "$MCP_FILE" ]]; then
    ACCESS_ID=$(python3 -c "
import json, sys
with open('${MCP_FILE}') as f:
    cfg = json.load(f)
args = cfg['mcpServers']['akeyless']['args']
for i, a in enumerate(args):
    if a == '--access-id' and i+1 < len(args):
        print(args[i+1]); sys.exit(0)
sys.exit(1)
" 2>/dev/null) || true

    UID_TOKEN=$(python3 -c "
import json, sys
with open('${MCP_FILE}') as f:
    cfg = json.load(f)
args = cfg['mcpServers']['akeyless']['args']
for i, a in enumerate(args):
    if a == '--uid-token' and i+1 < len(args):
        print(args[i+1]); sys.exit(0)
sys.exit(1)
" 2>/dev/null) || true

    if [[ -n "$ACCESS_ID" && -n "$UID_TOKEN" ]]; then
        if AUTH_OUT=$(akeyless auth \
            --access-type universal_identity \
            --access-id "$ACCESS_ID" \
            --uid-token "$UID_TOKEN" \
            --gateway-url "${GATEWAY_URL}/api/v2" 2>&1); then
            pass "Universal Identity auth succeeded (access-id: ${ACCESS_ID})"
        else
            fail "Universal Identity auth failed: $(echo "$AUTH_OUT" | head -1)"
        fi
    else
        fail "Could not extract access-id / uid-token from ${MCP_FILE}"
    fi
else
    fail "${MCP_FILE} not found — run from project root"
fi

# ── 6. Python mysql-connector-python ─────────────────────────
echo -e "${BOLD}6. Python Dependencies${RESET}"
if python3 -c "import mysql.connector" 2>/dev/null; then
    pass "mysql-connector-python installed"
else
    fail "mysql-connector-python not installed (pip install mysql-connector-python)"
fi

# ── 7. Demo files exist ──────────────────────────────────────
echo -e "${BOLD}7. Demo Files${RESET}"
ALL_FILES_OK=true
for f in app/insecure_query.py .mcp.json; do
    if [[ -f "$f" ]]; then
        pass "File exists: ${f}"
    else
        fail "Missing file: ${f}"
        ALL_FILES_OK=false
    fi
done

# ── 8. Port-forward & demo data (optional) ───────────────────
echo -e "${BOLD}8. MySQL Port-Forward & Demo Data${RESET}"
if nc -z 127.0.0.1 3306 2>/dev/null; then
    ROW_COUNT=$(python3 -c "
import mysql.connector, sys
try:
    conn = mysql.connector.connect(host='127.0.0.1', port=3306, user='root', password='DemoRoot2026', database='demo')
    cur = conn.cursor()
    cur.execute('SELECT COUNT(*) FROM customers')
    count = cur.fetchone()[0]
    print(count)
    conn.close()
except Exception as e:
    print(f'error: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null) || true

    if [[ "$ROW_COUNT" == "10" ]]; then
        pass "demo.customers table has 10 rows"
    elif [[ -n "$ROW_COUNT" && "$ROW_COUNT" =~ ^[0-9]+$ ]]; then
        fail "demo.customers table has ${ROW_COUNT} rows (expected 10)"
    else
        fail "Could not query demo.customers table"
    fi
else
    skip "Port-forward not active on 127.0.0.1:3306 — skipping data check"
fi

# ── 9. Akeyless MCP server starts correctly ──────────────────
echo -e "${BOLD}9. Akeyless MCP Server${RESET}"
if [[ -f "$MCP_FILE" ]]; then
    INIT_MSG='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"preflight","version":"0.1.0"}}}'

    # Build the MCP server command from .mcp.json
    MCP_CMD=$(python3 -c "
import json
with open('${MCP_FILE}') as f:
    cfg = json.load(f)
srv = cfg['mcpServers']['akeyless']
cmd = srv['command']
args = srv.get('args', [])
import shlex
print(shlex.join([cmd] + args))
" 2>/dev/null) || true

    if [[ -n "$MCP_CMD" ]]; then
        MCP_RESPONSE=$(echo "$INIT_MSG" | timeout 15 bash -c "$MCP_CMD" 2>/dev/null | head -1 || true)
        if echo "$MCP_RESPONSE" | python3 -c "
import json, sys
try:
    resp = json.loads(sys.stdin.read())
    assert resp.get('jsonrpc') == '2.0'
    assert 'result' in resp
    sys.exit(0)
except Exception:
    sys.exit(1)
" 2>/dev/null; then
            pass "MCP server responded to initialize request"
        else
            fail "MCP server did not return a valid JSON-RPC response"
        fi
    else
        fail "Could not build MCP server command from ${MCP_FILE}"
    fi
else
    fail "${MCP_FILE} not found — cannot test MCP server"
fi

# ── Summary ──────────────────────────────────────────────────
TOTAL=$((PASS_COUNT + FAIL_COUNT + SKIP_COUNT))
echo ""
echo -e "${BOLD}── Summary ──${RESET}"
echo -e "  ${GREEN}Passed: ${PASS_COUNT}${RESET}  ${RED}Failed: ${FAIL_COUNT}${RESET}  ${YELLOW}Skipped: ${SKIP_COUNT}${RESET}  Total: ${TOTAL}"
echo ""

if [[ "$FAIL_COUNT" -gt 0 ]]; then
    echo -e "${RED}${BOLD}Some checks failed. Please fix the issues above before the demo.${RESET}"
    exit 1
else
    echo -e "${GREEN}${BOLD}All checks passed — ready for demo!${RESET}"
    exit 0
fi
