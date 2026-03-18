# Securing AI Agents Webinar -- Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare all deliverables for a 45-minute Akeyless webinar: slide deck (markdown), tested demo environment, tmux demo script, and blog post outline.

**Architecture:** The webinar has three phases: 15 min slides (markdown-based), 15 min live demo (tmux split-screen with Claude Code), 15 min Q&A. The demo compares an insecure Python script (hardcoded MySQL creds) against Akeyless MCP server with Universal Identity + Dynamic Secrets. All Akeyless infrastructure is already configured.

**Tech Stack:** Markdown slides, Python 3, MySQL 8.0, Akeyless CLI v1.139+, Akeyless MCP server, Claude Code, tmux, kubectl

**Spec:** `docs/superpowers/specs/2026-03-18-securing-ai-agents-webinar-design.md`

---

## What's Already Done

The following was completed during the brainstorming/design phase:

- [x] Akeyless target `/demo-ai-agents/mysql-target` created and tested
- [x] Akeyless dynamic secret producer `/demo-ai-agents/mysql-dynamic-secret` created (SELECT on demo.*, 5-min TTL)
- [x] Universal Identity auth method `/demo-ai-agents/ai-agent-uid` created with role association
- [x] UID token generated and tested
- [x] `.mcp.json` configured and working in Claude Code
- [x] MySQL `demo.customers` table seeded with 10 enterprise records
- [x] `app/insecure_query.py` created
- [x] `setup/seed.sql` created
- [x] `requirements.txt` created
- [x] `mysql-connector-python` installed

---

## File Map

| File | Status | Responsibility |
|------|--------|----------------|
| `slides/slides.md` | Create | Markdown slide deck with speaker notes |
| `scripts/demo-setup.sh` | Create | Automated pre-demo environment setup/validation |
| `scripts/tmux-demo.sh` | Create | tmux session launcher for the split-screen demo |
| `app/insecure_query.py` | Exists | "The Old Way" demo script |
| `.mcp.json` | Exists | Akeyless MCP config for Claude Code |
| `setup/seed.sql` | Exists | MySQL schema and seed data |
| `requirements.txt` | Exists | Python dependencies |
| `README.md` | Modify | Update with project overview, setup instructions, and demo guide |

---

### Task 1: Create Markdown Slide Deck

**Files:**
- Create: `slides/slides.md`

- [ ] **Step 1: Create slides directory**

```bash
mkdir -p slides
```

- [ ] **Step 2: Write the slide deck**

Create `slides/slides.md` with all 11 slides from the spec. Each slide uses `---` separator. Include speaker notes as blockquotes under each slide. Content sources:

- Slides 2-5: Stats and narrative from Akeyless PDF (pages 2-4, 10)
- Slides 6-7: Diagrams described in text (lifecycle, maturity model)
- Slide 8: Akeyless product capabilities from web research
- Slide 9: Architecture flow from PDF page 16
- Slides 10-11: Transition and CTA

Speaker notes should include:
- Exact talking points from the spec
- Timing targets per slide
- Transition cues to next slide

- [ ] **Step 3: Review slides for accuracy**

Cross-reference every stat with its source:
- "80% unintended actions" -> SailPoint/Dimensional Research, May 2025
- "1 in 5 security incident" -> Neural Trust, Nov 2025
- "144:1 NHI ratio" -> Entro Labs H1 2025
- "24M leaked credentials" -> GitGuardian, April 2025
- Salesloft-Drift breach -> verify against public reporting (not just Akeyless PDF)

- [ ] **Step 4: Commit**

```bash
git add slides/slides.md
git commit -m "feat: add markdown slide deck for securing AI agents webinar"
```

---

### Task 2: Create Demo Setup Script

**Files:**
- Create: `scripts/demo-setup.sh`

- [ ] **Step 1: Write the setup/validation script**

Create `scripts/demo-setup.sh` that automates and validates the entire pre-demo checklist:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

echo "=== Securing AI Agents Demo - Pre-flight Check ==="
echo ""

# 1. Check akeyless CLI
echo "Checking akeyless CLI..."
which /usr/bin/akeyless >/dev/null 2>&1 && pass "akeyless CLI found at /usr/bin/akeyless" || fail "akeyless CLI not found at /usr/bin/akeyless"

# 2. Check akeyless CLI version >= 1.130.0
echo "Checking akeyless CLI version..."
VERSION=$(akeyless --version 2>/dev/null | grep -oP 'Version: \K[0-9.]+')
pass "akeyless CLI version: $VERSION"

# 3. Check gateway reachability
echo "Checking Akeyless gateway..."
curl -sk https://192.168.1.82:8000/status >/dev/null 2>&1 && pass "Gateway reachable at 192.168.1.82:8000" || fail "Gateway not reachable"

# 4. Check MySQL pod
echo "Checking MySQL pod..."
kubectl get pod -n akeyless -l app=demo-mysql --no-headers 2>/dev/null | grep -q Running && pass "MySQL pod running" || fail "MySQL pod not running"

# 5. Check dynamic secret producer
echo "Checking dynamic secret producer..."
akeyless dynamic-secret get-value --name /demo-ai-agents/mysql-dynamic-secret --profile demo >/dev/null 2>&1 && pass "Dynamic secret producer works" || fail "Dynamic secret producer failed"

# 6. Check UID auth
echo "Checking Universal Identity auth..."
UID_TOKEN=$(python3 -c "import json; d=json.load(open('.mcp.json')); args=d['mcpServers']['akeyless']['args']; print(args[args.index('--uid-token')+1])")
ACCESS_ID=$(python3 -c "import json; d=json.load(open('.mcp.json')); args=d['mcpServers']['akeyless']['args']; print(args[args.index('--access-id')+1])")
akeyless auth --access-type universal_identity --access-id "$ACCESS_ID" --uid-token "$UID_TOKEN" --gateway-url https://192.168.1.82:8000/api/v2 >/dev/null 2>&1 && pass "UID authentication works" || fail "UID authentication failed"

# 7. Check Python deps
echo "Checking Python dependencies..."
python3 -c "import mysql.connector" 2>/dev/null && pass "mysql-connector-python installed" || fail "mysql-connector-python not installed (run: pip install mysql-connector-python)"

# 8. Check insecure script exists
echo "Checking demo files..."
[ -f app/insecure_query.py ] && pass "app/insecure_query.py exists" || fail "app/insecure_query.py missing"
[ -f .mcp.json ] && pass ".mcp.json exists" || fail ".mcp.json missing"

# 9. Check demo data
echo "Checking demo data (requires port-forward)..."
if nc -z 127.0.0.1 3306 2>/dev/null; then
    ROW_COUNT=$(python3 -c "
import mysql.connector
conn = mysql.connector.connect(host='127.0.0.1', port=3306, user='root', password='DemoRoot2026', database='demo')
cursor = conn.cursor()
cursor.execute('SELECT COUNT(*) FROM customers')
print(cursor.fetchone()[0])
conn.close()
")
    [ "$ROW_COUNT" -eq 10 ] && pass "customers table has $ROW_COUNT rows" || fail "customers table has $ROW_COUNT rows (expected 10)"
else
    echo -e "${RED}[SKIP]${NC} Port-forward not active. Run: kubectl port-forward svc/demo-mysql -n akeyless 3306:3306 &"
fi

echo ""
echo "=== Pre-flight check complete ==="
```

- [ ] **Step 2: Make executable and test**

```bash
chmod +x scripts/demo-setup.sh
./scripts/demo-setup.sh
```

Expected: All checks pass (except demo data if port-forward not running).

- [ ] **Step 3: Commit**

```bash
git add scripts/demo-setup.sh
git commit -m "feat: add demo pre-flight validation script"
```

---

### Task 3: Create tmux Demo Launcher

**Files:**
- Create: `scripts/tmux-demo.sh`

- [ ] **Step 1: Write the tmux launcher**

Create `scripts/tmux-demo.sh` that sets up the exact demo layout:

```bash
#!/usr/bin/env bash
set -euo pipefail

SESSION="akeyless-demo"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Kill existing session if any
tmux kill-session -t "$SESSION" 2>/dev/null || true

# Create new session with 3 panes
# Pane 0 (left): "The Old Way" - Claude Code for insecure demo
# Pane 1 (right): "The Secretless Way" - Claude Code with MCP
# Pane 2 (bottom-right, small): port-forward (hidden during demo)

tmux new-session -d -s "$SESSION" -x 200 -y 50

# Start port-forward in the initial pane
tmux send-keys -t "$SESSION" "kubectl port-forward svc/demo-mysql -n akeyless 3306:3306" C-m
sleep 2

# Split vertically for the two Claude Code panes
tmux split-window -h -t "$SESSION"

# Right pane: launch Claude Code in project dir (with MCP)
tmux send-keys -t "$SESSION:0.1" "cd $PROJECT_DIR && echo '=== THE SECRETLESS WAY ===' && echo 'Launch Claude Code here: claude'" C-m

# Left pane: launch Claude Code in project dir (insecure demo)
tmux select-pane -t "$SESSION:0.0"
tmux send-keys -t "$SESSION:0.0" "cd $PROJECT_DIR && echo '=== THE OLD WAY ===' && echo 'Launch Claude Code here: claude'" C-m

# Set pane titles (if terminal supports it)
tmux select-pane -t "$SESSION:0.0" -T "The Old Way"
tmux select-pane -t "$SESSION:0.1" -T "The Secretless Way"

# Increase font readability hint
echo ""
echo "Demo session '$SESSION' created!"
echo ""
echo "BEFORE PRESENTING:"
echo "  1. Increase terminal font to 18pt+"
echo "  2. In LEFT pane:  run 'claude' (for insecure demo)"
echo "  3. In RIGHT pane: run 'claude' (for MCP demo)"
echo "  4. Disable desktop notifications"
echo "  5. Open Akeyless console with 3 tabs: audit log, AI Insights, dynamic secret config"
echo ""
echo "Attaching to session..."

tmux attach-session -t "$SESSION"
```

- [ ] **Step 2: Make executable and test**

```bash
chmod +x scripts/tmux-demo.sh
./scripts/tmux-demo.sh
```

Expected: tmux session opens with two panes, port-forward running in background.

- [ ] **Step 3: Commit**

```bash
git add scripts/tmux-demo.sh
git commit -m "feat: add tmux demo launcher for split-screen presentation"
```

---

### Task 4: Update README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Rewrite README with project overview and demo instructions**

```markdown
# Securing AI Agents with Akeyless

Demo repository for the webinar: **Securing AI Agents: How Identity-Based Access and Dynamic Credentials Enable Secure AI Automation**

## What This Demonstrates

An AI agent (Claude Code) authenticating to Akeyless via Universal Identity, retrieving dynamic MySQL credentials with a 5-minute TTL, and querying a database -- with zero hardcoded secrets.

Compared side-by-side with the traditional approach: hardcoded database credentials in source code.

## Architecture

```
AI Agent (Claude Code)
    |
    v
Akeyless MCP Server (akeyless mcp)
    |-- Authenticates via Universal Identity (no secret zero)
    v
Akeyless Platform
    |-- Evaluates policy, issues dynamic credential
    v
MySQL Database
    |-- Ephemeral user (SELECT-only, 5-min TTL)
    |-- Auto-deleted on expiry
```

## Prerequisites

- Akeyless CLI >= 1.130.0
- Akeyless account with gateway access
- Kubernetes cluster with MySQL deployment
- Python 3.x with `mysql-connector-python`
- Claude Code with MCP support

## Quick Start

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Seed the database** (if starting fresh):
   ```bash
   kubectl exec -n akeyless <mysql-pod> -- mysql -uroot -p<password> < setup/seed.sql
   ```

3. **Configure Akeyless MCP server:**
   Copy `.mcp.json.example` to `.mcp.json` and fill in your credentials.

4. **Run pre-flight checks:**
   ```bash
   ./scripts/demo-setup.sh
   ```

5. **Launch the demo:**
   ```bash
   ./scripts/tmux-demo.sh
   ```

## Repository Structure

```
.
├── app/
│   └── insecure_query.py      # "The Old Way" - hardcoded credentials
├── scripts/
│   ├── demo-setup.sh          # Pre-flight validation
│   └── tmux-demo.sh           # Demo session launcher
├── setup/
│   └── seed.sql               # MySQL schema and seed data
├── slides/
│   └── slides.md              # Markdown slide deck
├── docs/
│   └── superpowers/
│       ├── specs/             # Webinar design spec
│       └── plans/             # Implementation plan
├── .mcp.json                  # Akeyless MCP config (git-ignored)
├── requirements.txt
└── README.md
```

## Webinar Format

| Segment | Duration | Content |
|---------|----------|---------|
| Slides | 15 min | The Maturity Journey: why AI agents need identity-based access |
| Live Demo | 15 min | Side-by-side: hardcoded secrets vs. Akeyless SecretlessAI |
| Q&A | 15 min | Open discussion |

## Resources

- [Akeyless MCP Server Docs](https://docs.akeyless.io/docs/mcp-server)
- [Universal Identity Docs](https://docs.akeyless.io/docs/auth-with-universal-identity)
- [Dynamic Secrets Docs](https://docs.akeyless.io/docs/how-to-create-dynamic-secret)
- [AI Agent Identity Security: 2026 Deployment Guide](https://www.akeyless.io/secure-ai-agents/)
```

- [ ] **Step 2: Create .mcp.json.example**

Create a sanitized example file that others can copy:

```json
{
  "mcpServers": {
    "akeyless": {
      "command": "/usr/bin/akeyless",
      "args": [
        "mcp",
        "--access-type", "universal_identity",
        "--access-id", "<YOUR_ACCESS_ID>",
        "--uid-token", "<YOUR_UID_TOKEN>",
        "--gateway-url", "https://<YOUR_GATEWAY_IP>:8000/api/v2"
      ]
    }
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add README.md .mcp.json.example
git commit -m "docs: update README with project overview and demo instructions"
```

---

### Task 5: Create Slide Deck Content

**Files:**
- Create: `slides/slides.md`

This is the largest task. Each slide follows the spec exactly, with speaker notes.

- [ ] **Step 1: Write all 11 slides**

The slide deck uses `---` as slide separators and `> **Speaker notes:**` for presenter guidance. Content is drawn directly from the spec (slides section) and the Akeyless PDF.

Key content to include:
- Slide 2: Gartner quote, 80% stat, 1 in 5 stat
- Slide 4: Salesloft-Drift breach 5-step breakdown
- Slide 6: 4-phase lifecycle diagram (text-based)
- Slide 7: 4-stage maturity progression
- Slide 8: 6 Akeyless capabilities with one-liners
- Slide 9: Architecture flow (text-based)
- Slide 11: CTA with links

- [ ] **Step 2: Proofread for timing**

Read through aloud. Target: ~1.5 min per slide, total ~15 min. Mark any slide that runs long.

- [ ] **Step 3: Commit**

```bash
git add slides/slides.md
git commit -m "feat: add webinar slide deck content"
```

---

### Task 6: Dry Run and Prompt Tuning

This task is manual (not code) but critical for demo reliability.

- [ ] **Step 1: Start the demo environment**

```bash
kubectl port-forward svc/demo-mysql -n akeyless 3306:3306 &
./scripts/demo-setup.sh
```

- [ ] **Step 2: Test left pane (insecure)**

Launch Claude Code in the project dir. Test these prompts and note which produces the cleanest output:

Prompt A: "Run the script at app/insecure_query.py"
Prompt B: "Execute app/insecure_query.py to query our customer database"
Prompt C: "Run python3 app/insecure_query.py"

Then test: "Can you find any hardcoded credentials in this project?"

- [ ] **Step 3: Test right pane (secretless)**

Launch Claude Code in the project dir (with .mcp.json). Test these prompts:

Prompt A: "Get me a dynamic secret for our MySQL database from Akeyless and query the customers table -- show me enterprise customers with revenue over $5M"
Prompt B: "Use the Akeyless MCP server to get a dynamic MySQL credential from /demo-ai-agents/mysql-dynamic-secret, then connect to the database and show me enterprise customers with annual revenue over 5 million"
Prompt C: "I need to query our MySQL database. Use Akeyless to get dynamic credentials and then show me the top enterprise customers by revenue"

Note which prompt:
- Triggers the MCP tool call reliably
- Produces clean, readable output
- Completes in under 2 minutes

- [ ] **Step 4: Test credential expiry**

After a successful query, wait 5 minutes and ask Claude Code to reconnect with the same credentials. Verify it fails.

- [ ] **Step 5: Document winning prompts**

Add the best prompts to the spec or a `scripts/demo-prompts.txt` file for reference during the live presentation.

- [ ] **Step 6: Commit prompt file**

```bash
git add scripts/demo-prompts.txt
git commit -m "docs: add tested demo prompts for reliable Claude Code behavior"
```

---

### Task 7: Final Validation

- [ ] **Step 1: Run full pre-flight check**

```bash
./scripts/demo-setup.sh
```

All checks must pass.

- [ ] **Step 2: Run full demo end-to-end**

Execute the complete demo script from the spec (Act 1, Act 2, Act 3) in under 15 minutes.

- [ ] **Step 3: Verify Akeyless console views**

Open Akeyless console and confirm:
- Audit log shows the dynamic secret request with agent identity
- AI Insights dashboard is accessible
- Dynamic secret producer config page shows SELECT-only grant
- Session revocation works

- [ ] **Step 4: Final commit with any fixes**

```bash
git add -A
git commit -m "chore: final demo validation and fixes"
```
