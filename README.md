# Securing AI Agents with Akeyless

Demo repository for the webinar **"Securing AI Agents: How Identity-Based Access and Dynamic Credentials Enable Secure AI Automation"**.

This demo shows an AI agent (Claude Code) authenticating to Akeyless via Universal Identity, retrieving dynamic MySQL credentials with a 5-minute TTL, and querying a database with zero hardcoded secrets. The secure approach is compared side-by-side with a traditional hardcoded-credentials pattern to illustrate the risks and the solution.

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

2. **Seed the database:**

   ```bash
   kubectl exec -n akeyless <mysql-pod> -- mysql -uroot -p<password> < setup/seed.sql
   ```

3. **Configure MCP:**

   Copy `.mcp.json.example` to `.mcp.json` and fill in your Akeyless credentials:

   ```bash
   cp .mcp.json.example .mcp.json
   ```

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
├── .mcp.json.example          # MCP server configuration template
├── README.md
├── LICENSE
├── requirements.txt           # Python dependencies
├── app/
│   └── insecure_query.py      # Hardcoded-credentials example (anti-pattern)
├── docs/
│   └── superpowers/
│       ├── plans/
│       │   └── 2026-03-18-securing-ai-agents-webinar.md
│       └── specs/
│           └── 2026-03-18-securing-ai-agents-webinar-design.md
├── scripts/
│   ├── demo-setup.sh          # Pre-flight validation script
│   └── tmux-demo.sh           # Tmux-based demo launcher
├── setup/
│   └── seed.sql               # MySQL schema and sample data
└── slides/
    └── slides.md              # Marp presentation slides
```

## Webinar Format

| Segment | Duration |
|---------|----------|
| Slides  | 15 min   |
| Demo    | 15 min   |
| Q&A     | 15 min   |

## Resources

- [Akeyless MCP Server Docs](https://docs.akeyless.io/docs/mcp-server)
- [Universal Identity Docs](https://docs.akeyless.io/docs/auth-with-universal-identity)
- [Dynamic Secrets Docs](https://docs.akeyless.io/docs/how-to-create-dynamic-secret)
- [AI Agent Identity Security Guide](https://www.akeyless.io/secure-ai-agents/)
