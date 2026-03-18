# Securing AI Agents Webinar -- Design Spec

## Overview

**Title:** Securing AI Agents: How Identity-Based Access and Dynamic Credentials Enable Secure AI Automation

**Client:** Akeyless
**Format:** 45-minute webinar (15 slides / 15 demo / 15 Q&A)
**Deliverables:** Slide deck, live demo environment, blog post (post-webinar)

**Core message:** AI agents are a new class of non-human identities that require secure, identity-based access instead of static credentials. Akeyless enables Secretless AI -- agents authenticate using machine identity and receive ephemeral credentials only when needed.

---

## Webinar Structure

### Approach

Slides follow the "Maturity Journey" narrative from Akeyless's 2026 AI Agent Identity Security Deployment Guide. The demo follows the "Live Build" approach -- starting with an insecure AI agent using hardcoded credentials and transforming it to secretless in real-time.

**Presentation format:** tmux split-screen terminal
- **Left pane:** Claude Code session -- "The Old Way" (hardcoded secrets)
- **Right pane:** Claude Code session -- "The Secretless Way" (Akeyless MCP + Universal Identity + Dynamic Secrets)

---

## Slide Deck (15 minutes, 10 slides)

### Slide 1 -- Title
- "Securing AI Agents: How Identity-Based Access and Dynamic Credentials Enable Secure AI Automation"
- Akeyless branding

### Slide 2 -- The Year AI Agents Began to Act
- Source: PDF Introduction (page 2)
- Gartner predicts 2026 = "AI agent sprawl"
- 80% of orgs admit agents took unintended actions (SailPoint/Dimensional Research, May 2025)
- 1 in 5 orgs experienced an AI agent security incident (Neural Trust, Nov 2025)
- Key point: agents aren't tools anymore -- they're actors with authority

### Slide 3 -- Where Agent Deployments Go Wrong
- Source: PDF Chapter 1 (page 3)
- Teams reuse existing credentials because they're already approved
- Permissions widened to avoid blocking workflows
- Secrets pass through agent execution paths without clear ownership
- Access persists because cleanup is deferred
- Non-human identities outnumber human 144:1 (Entro Labs, H1 2025)

### Slide 4 -- The Salesloft-Drift Breach (2025)
- Source: PDF Chapter 3 (page 10)
- Stolen OAuth tokens from an automated Drift-Salesloft integration
- Tokens were long-lived and broadly trusted
- Enabled cross-system access to Salesforce customer environments
- Detected only after unusual access patterns emerged -- not at the moment of misuse
- Takeaway: long-lived tokens in automated systems = standing access for attackers

### Slide 5 -- AI Agents Are an Identity Problem
- Source: PDF Chapter 1 (pages 3-4)
- Agents decide and act -- they need identity, not just credentials
- Traditional IdPs (Okta, Entra ID) built for humans, not autonomous systems
- The question isn't "does the agent have the right answer" -- it's "should it have been allowed to act at all"
- The convergence of human, machine, and agent identity requires a unified approach

### Slide 6 -- The AI Agent Identity Lifecycle
- Source: PDF Chapter 2 (page 5)
- 4-phase diagram: Provisioning -> Authorization & Scoping -> Runtime Enforcement -> Deprovisioning
- Provisioning: assign unique, policy-bound identity to verified agent
- Authorization: define least-privilege access, task-specific, time-bound
- Runtime: monitor agent behavior, ensure it stays within granted permissions
- Deprovisioning: revoke access, invalidate credentials, preserve evidence

### Slide 7 -- The 4-Stage Maturity Model
- Source: PDF Chapter 2 (page 8)
- Stage 1: Static Secrets -- secrets in source code, config files, vaults (where most orgs are)
- Stage 2: Auto-Rotation -- periodic rotation of credentials and API keys
- Stage 3: Dynamic Identities -- Zero Standing Privileges, temporary identities created on demand
- Stage 4: Secretless -- OAuth, OIDC, SPIFFE & ZSP, "SSO for Machines"
- Arrow: "AI agents are the forcing function that pushes you to Stage 4"

### Slide 8 -- Akeyless: Identity Security for AI Agents
- SecretlessAI -- JIT identity-based auth, no embedded secrets
- AI Agent Identity Provider -- verifiable federated identities for agents
- Universal Identity -- solves secret zero, child token hierarchies, auto-rotation
- Dynamic Secrets -- ephemeral credentials with TTL for databases, cloud, SaaS
- AI Insights -- anomaly detection, audit, automated remediation
- MCP Integration -- native `akeyless mcp` command for AI tools (Claude, Cursor, VS Code, Copilot)

### Slide 9 -- Architecture Diagram
- Source: PDF Chapter 5 (page 16)
- Flow: AI Agent -> MCP Server -> Akeyless API -> Target System -> Credential Retrieval
- Annotated: "No secrets in agent code. No standing privileges. Full audit trail."
- Show target systems: databases, cloud providers (AWS/Azure), SaaS (Slack, Salesforce, ServiceNow)

### Slide 10 -- Transition to Demo
- "We're going from Stage 1 -- static secrets in code -- straight to Stage 4 -- secretless, identity-based access. Watch."
- Two-column preview: Before (hardcoded password in code) vs. After (Akeyless MCP + dynamic secrets)

### Slide 11 -- Closing CTA (shown after Q&A)
- "Get Started with Secretless AI"
- Link to Akeyless MCP Server docs: docs.akeyless.io/docs/mcp-server
- Link to AI Agent Identity Security Deployment Guide (PDF)
- Request a demo: akeyless.io/demo
- Contact info

---

## Live Demo Script (15 minutes)

### Setup

**Presentation:** tmux with two panes side-by-side
- Left pane: Claude Code session in a directory with `insecure_query.py`
- Right pane: Claude Code session in the `akeyless-secure-ai-agents` project (with `.mcp.json` configured)

### Act 1: "The Old Way" -- Left Pane (~3 minutes)

**Pre-staged file:** `app/insecure_query.py`

```python
import mysql.connector

# Database credentials
DB_HOST = "127.0.0.1"
DB_PORT = 3306
DB_USER = "root"
DB_PASSWORD = "DemoRoot2026"
DB_NAME = "demo"

def query_customers():
    conn = mysql.connector.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )
    cursor = conn.cursor()
    cursor.execute("SELECT company_name, contact_name, contract_tier, annual_revenue FROM customers")
    results = cursor.fetchall()
    for row in results:
        print(f"{row[0]} | {row[1]} | {row[2]} | ${row[3]:,.2f}")
    conn.close()

if __name__ == "__main__":
    query_customers()
```

**Demo flow:**
1. Show the file: "This is how most AI agents access databases today."
2. Ask Claude Code (left pane): "Run this script to query our customer database."
3. It works -- results display.
4. Talking points while results show:
   - "That password is in source code. It's in memory. Probably in git history."
   - "It's a permanent credential -- works forever until someone manually revokes it."
   - "If this agent is compromised, the attacker has the same access indefinitely."
5. Ask Claude Code: "Can you find any hardcoded credentials in this project?"
6. Claude flags the hardcoded password.
7. **Punch line:** "Let's kill this. No more static credentials."

### Act 2: "The Secretless Way" -- Right Pane (~7 minutes)

**Step 1 -- Show the MCP config (~1 min)**

Switch to right pane. Show the `.mcp.json` file:

```
cat .mcp.json
```

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
        "--gateway-url", "https://192.168.1.82:8000/api/v2"
      ]
    }
  }
}
```

**Talking points:**
- "This is the entire configuration. Three lines that matter."
- "The AI agent authenticates via Universal Identity -- Akeyless's answer to the secret zero problem."
- "No passwords, no API keys, no connection strings. Just an identity."
- "The UID token rotates automatically -- even if intercepted, it's short-lived."

**Step 2 -- Retrieve dynamic MySQL credential (~3 min)**

Ask Claude Code (right pane): "Get me a dynamic secret for our MySQL database from Akeyless and query the customers table -- show me enterprise customers with revenue over $5M."

Claude Code uses the Akeyless MCP server to:
1. Authenticate to Akeyless via Universal Identity (transparent)
2. Call the dynamic secret producer `/demo-ai-agents/mysql-dynamic-secret`
3. Receive ephemeral username + password with 5-minute TTL
4. Connect to MySQL, run the query, display results

**Talking points as this happens:**
- "Akeyless just created a temporary MySQL user on the fly."
- "This user has SELECT-only permissions -- least privilege, exactly what the task needs."
- "In 5 minutes, this user is automatically deleted. Zero standing privileges."

**Step 3 -- Show the credential is temporary (~1 min)**

Ask Claude Code: "What were the credentials you just used? When do they expire?"

Claude shows the ephemeral username (tmp_p-9l5f_XXXXX) and 5-minute TTL.

**Talking point:** "These credentials existed only in memory, only for this session. They never touched disk, never hit a config file, never entered git. And they're already counting down to self-destruct."

**Step 4 -- Side-by-side comparison (~2 min)**

Point at both panes:
- Left: "Hardcoded password. Permanent. In source code. One compromise = game over."
- Right: "Dynamic identity. Ephemeral. In memory only. One compromise = 5 minutes of read-only access."

### Act 3: "The Governance View" -- Browser (~5 minutes)

Switch to Akeyless console in a browser.

**Show 1 -- Audit log (~2 min)**
- Navigate to the audit log
- Find the dynamic secret request from the demo
- Show: which identity requested it, when, what was issued, TTL, expiration
- "Every AI agent action is attributed to a specific identity. No shared service accounts. Full accountability."

**Show 2 -- Permission scope + AI Insights (~2 min)**
- Show the dynamic secret producer config: SELECT-only on demo.* -- reinforce least privilege
- Show AI Insights agent activity dashboard
- Anomaly detection: "If this agent suddenly requested 50 credentials in a minute instead of 1, Akeyless flags it."
- "This is the difference between observability and control -- not just seeing what happened, but being able to stop it."
- **Timing cue:** If past 12 minutes in demo, mention AI Insights verbally and skip to revocation.

**Show 3 -- Revoke a session (~1 min)**
- Demonstrate one-click session/token revocation
- "If an agent is compromised, you revoke its identity -- not rotate every secret it ever touched."

**Closing line:** "We went from hardcoded password to secretless, identity-based, audited, auto-expiring access. No application code changes. Just configuration and identity."

---

## Demo Environment

### Infrastructure (existing)

| Component | Location | Details |
|-----------|----------|---------|
| Akeyless Gateway | 192.168.1.82:8000 | Running in `akeyless` namespace on k3s |
| MySQL Database | `demo-mysql.akeyless.svc.cluster.local:3306` | MySQL 8.0, `akeyless` namespace |
| Demo Database | `demo` | `customers` table, 10 enterprise records |

### Akeyless Configuration (created)

| Item | Path | Details |
|------|------|---------|
| MySQL Target | `/demo-ai-agents/mysql-target` | Points to demo-mysql service |
| Dynamic Secret Producer | `/demo-ai-agents/mysql-dynamic-secret` | SELECT on demo.*, 5-min TTL |
| Universal Identity Auth | `/demo-ai-agents/ai-agent-uid` | Access ID: `<YOUR_ACCESS_ID>` |
| Role | `/demo-ai-agents/ai-agent-role` | read/list on `/demo-ai-agents/*` |
| UID Token | (in .mcp.json) | Auto-rotating |

### Claude Code MCP Config

File: `.mcp.json` in project root, using `akeyless mcp` with Universal Identity auth.

### Demo Data

`demo.customers` table:

| company_name | contact_name | contract_tier | annual_revenue | region |
|---|---|---|---|---|
| Acme Corp | Sarah Chen | Enterprise | $2,450,000 | US-West |
| GlobalTech Industries | James Rodriguez | Enterprise | $8,900,000 | US-East |
| Nordic Systems AB | Erik Lindgren | Professional | $1,200,000 | EU-North |
| Quantum AI Labs | Priya Sharma | Enterprise | $5,600,000 | APAC |
| SecureStack Ltd | Tom Bradley | Professional | $890,000 | EU-West |
| DataFlow Systems | Maria Santos | Starter | $340,000 | LATAM |
| CloudBridge Networks | Alex Kim | Enterprise | $4,200,000 | APAC |
| Pinnacle Finance Group | Robert Fischer | Enterprise | $12,000,000 | US-East |
| GreenEnergy Solutions | Anna Mueller | Professional | $1,800,000 | EU-Central |
| TechVentures Inc | David Park | Starter | $560,000 | US-West |

---

## Files to Create in Repo

| File | Purpose |
|------|---------|
| `.mcp.json` | Akeyless MCP server config for Claude Code (created) |
| `.gitignore` | Exclude .mcp.json and logs (created) |
| `app/insecure_query.py` | "The Old Way" demo script with hardcoded creds |
| `requirements.txt` | Python dependencies (mysql-connector-python) |
| `setup/seed.sql` | MySQL schema and seed data for reproducible setup |
| `docs/superpowers/specs/2026-03-18-securing-ai-agents-webinar-design.md` | This spec |

---

## Blog Post Outline (post-webinar)

The webinar content converts to a blog post with the following structure:

### Title
"Securing AI Agents: From Hardcoded Secrets to Secretless with Akeyless"

### Sections
1. **The AI Agent Identity Crisis** -- stats, the problem (from slides 2-3)
2. **When Long-Lived Tokens Become Attack Vectors** -- Salesloft-Drift case study (slide 4)
3. **Why AI Agents Need Identity, Not Just Credentials** -- identity lifecycle, maturity model (slides 5-7)
4. **Akeyless SecretlessAI in Practice** -- product capabilities (slide 8)
5. **Demo Walkthrough: Hardcoded to Secretless in 15 Minutes** -- step-by-step with screenshots/code from the demo
6. **The Governance Layer** -- audit, AI Insights, revocation (Act 3 of demo)
7. **Getting Started** -- link to Akeyless MCP docs, deployment guide PDF, demo request

---

## Pre-Demo Checklist

### Infrastructure
- [ ] Akeyless gateway accessible at 192.168.1.82:8000 **from the presentation machine/network**
- [ ] MySQL pod running in akeyless namespace (`kubectl get pods -n akeyless | grep mysql`)
- [ ] `demo.customers` table populated with 10 rows
- [ ] Run `kubectl port-forward svc/demo-mysql -n akeyless 3306:3306` in a **background tmux pane** (not one of the two visible panes)
- [ ] Test port-forward stability: run a query, wait 2 minutes, run another query

### Akeyless
- [ ] Dynamic secret producer `/demo-ai-agents/mysql-dynamic-secret` functional (test: `akeyless dynamic-secret get-value --name /demo-ai-agents/mysql-dynamic-secret --profile demo`)
- [ ] UID auth method working (test: `akeyless auth --access-type universal_identity --access-id <YOUR_ACCESS_ID> --uid-token <YOUR_UID_TOKEN> --gateway-url https://192.168.1.82:8000/api/v2`)
- [ ] Verify `/usr/bin/akeyless` binary exists at that exact path on presentation machine

### Claude Code
- [ ] Claude Code picks up `.mcp.json` and Akeyless MCP tools are available (check with `/mcp`)
- [ ] Do 3-5 dry runs to find the most reliable prompt wording for Claude Code
- [ ] `app/insecure_query.py` in place for left pane demo
- [ ] `pip install mysql-connector-python` installed

### Presentation Setup
- [ ] tmux configured: 3 panes (left = insecure Claude, right = secretless Claude, background = port-forward)
- [ ] Terminal font size: minimum 18pt for readability
- [ ] Dark theme with high contrast
- [ ] Disable desktop notifications
- [ ] Akeyless console open in browser with 3 pre-opened tabs: audit log, AI Insights, dynamic secret config
- [ ] Record the webinar for on-demand viewing and blog post screenshots

### Fallback Commands (if MCP server fails)
```bash
# Authenticate via UID
akeyless auth --access-type universal_identity \
  --access-id <YOUR_ACCESS_ID> \
  --uid-token <YOUR_UID_TOKEN> \
  --gateway-url https://192.168.1.82:8000/api/v2

# Get dynamic MySQL credential
akeyless dynamic-secret get-value \
  --name /demo-ai-agents/mysql-dynamic-secret \
  --profile demo
```

### Demo Reset Procedure (between dry runs or after failed attempt)
```bash
# Kill lingering port-forwards
pkill -f "kubectl port-forward.*demo-mysql"

# Restart port-forward
kubectl port-forward svc/demo-mysql -n akeyless 3306:3306 &

# Clear Claude Code sessions (exit and relaunch from project dir)
# Verify MCP server reconnects
```

---

## Q&A Preparation (15 minutes)

### Anticipated Questions

**"How does Universal Identity solve the secret zero problem?"**
UID provides an inherited identity derived from the parent system. The initial token rotates automatically, so even if intercepted, it's short-lived. No hardcoded secret needed to bootstrap the agent.

**"What happens if the UID token is compromised?"**
The token has a TTL and rotates. You can also revoke the auth method instantly from the Akeyless console, killing all sessions.

**"Can this work with AWS IAM / Azure AD / GCP instead of Universal Identity?"**
Yes -- the Akeyless MCP server supports 13 auth methods including aws_iam, azure_ad, gcp, k8s, cert, jwt, oidc, saml, and more. UID is ideal for environments without a cloud IdP.

**"What about multi-agent scenarios with different permission levels?"**
Universal Identity supports child token hierarchies. A parent orchestrator can spawn child agents, each with scoped permissions and independent TTLs.

**"How is this different from just using HashiCorp Vault?"**
Akeyless is SaaS-native with zero-knowledge architecture (DFC). No self-hosted infrastructure. Plus the AI Agent IdP, AI Insights, and native MCP integration are purpose-built for AI agent workflows.

**"What about n8n / LangChain / other orchestrators?"**
Akeyless has an n8n community node. For any orchestrator, the MCP server or REST API can be used. The pattern is the same: authenticate with identity, get dynamic credentials, auto-expire.

---

## References

- Akeyless AI Agent Identity Security: The 2026 Deployment Guide (PDF)
- [Akeyless Secure AI Agents](https://www.akeyless.io/secure-ai-agents/)
- [Akeyless SecretlessAI Blog](https://www.akeyless.io/blog/akeyless-launches-secretlessai-pioneering-approach-to-secure-ai-agents/)
- [Akeyless MCP Server Docs](https://docs.akeyless.io/docs/mcp-server)
- [Universal Identity Docs](https://docs.akeyless.io/docs/auth-with-universal-identity)
- [Dynamic Secrets Docs](https://docs.akeyless.io/docs/how-to-create-dynamic-secret)
- [Akeyless n8n Node Announcement](https://nhimg.org/community/nhi-product-announcements-forum/new-akeyless-node-for-n8n-enhances-workflow-and-ai-agent-security/)
