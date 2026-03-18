# Securing AI Agents

## How Identity-Based Access and Dynamic Credentials Enable Secure AI Automation

**Presented by Akeyless**

> **Speaker notes:** Welcome everyone. Today we are tackling one of the most urgent security challenges of 2026: how to secure AI agents that act autonomously inside your infrastructure. Over the next 15 minutes of slides and a live demo, we will show you why identity-based access and dynamic credentials are the answer. (~1.5 min)

---

## The Year AI Agents Began to Act

- **Gartner** predicts 2026 = "a new wave of turbulence in the form of AI agent sprawl"
  *(Gartner, Dec 2025)*

- **80%** of organizations using AI agents admitted their agents took unintended actions, including unauthorized system access and data sharing
  *(SailPoint/Dimensional Research, May 2025)*

- **1 in 5** organizations experienced at least one AI agent-related security incident
  *(Neural Trust, Nov 2025)*

**"The question stops being whether an agent produces the right answer and becomes whether it should have been allowed to act at all."**

> **Speaker notes:** These are not hypothetical risks. Gartner is warning about agent sprawl this year. SailPoint found that four out of five organizations saw their agents take unintended actions -- unauthorized access, unplanned data sharing. One in five had an actual security incident. The shift is fundamental: we have moved from evaluating AI output quality to evaluating whether an agent should have been allowed to act in the first place. Transition: Let us look at how this plays out in practice. (~1.5 min)

---

## Where Agent Deployments Go Wrong

- Teams **reuse existing credentials** because they are already approved
- They **widen permissions** to avoid blocking workflows
- Secrets pass through agent execution paths and connected tools **without clear ownership**
- Access **persists** because cleanup is deferred
- Non-human identities outnumber human identities by **144:1**
  *(Entro Labs, H1 2025)*

**"Each choice seems contained, but together they form a pattern that becomes hard to explain and harder to defend."**

> **Speaker notes:** This is the pattern we see in every organization deploying agents. No single decision looks dangerous in isolation. Teams grab existing service accounts, open up permissions so demos work, pass secrets through chains of tools, and never get around to cleanup. Entro Labs found that non-human identities now outnumber human identities 144 to 1. That is the scale of the problem. Transition: Here is what happens when these patterns meet a real attacker. (~1.5 min)

---

## The Salesloft-Drift Breach (2025)

A real-world example of what standing access enables:

1. **Token compromise** -- OAuth access and refresh tokens from the Drift-Salesloft integration were stolen
2. **Valid authentication** -- Requests made with stolen tokens authenticated successfully to Salesforce
3. **Cross-system access** -- Tokens enabled access to Salesforce data across customer environments
4. **Late detection** -- Abuse was detected only after unusual access patterns emerged, not at the moment of misuse
5. **Manual containment** -- Response required revoking tokens, rotating credentials, and auditing access after the fact

**"Long-lived tokens in automated integrations function as standing access. Once exposed, they can be replayed across systems with little friction."**

> **Speaker notes:** This breach is a textbook case. Stolen OAuth tokens from a SaaS integration passed authentication checks across multiple Salesforce environments. Detection came late -- only after anomalous patterns were noticed. Containment was entirely manual. The root cause was not a sophisticated exploit; it was long-lived tokens providing standing access. This is exactly the pattern AI agents inherit when we wire them up with static credentials. Transition: So what is the right framing for this problem? (~1.5 min)

---

## AI Agents Are an Identity Problem

**"When software can decide and act inside live environments, the consequences of its decisions matter as much as the quality of its outputs."**

- Traditional IdPs (Okta, Entra ID) were built for **humans**, not autonomous systems
- AI agents do not fit the old mold:
  - Behavior shaped by context
  - Tools selected dynamically
  - Movement across environments
- **"Actors require identity, and identity brings access control and accountability into scope."**
- The convergence of **human, machine, and agent identity** requires a unified approach

> **Speaker notes:** This is the conceptual shift. AI agents are actors. They make decisions, select tools, and execute across systems. Traditional identity providers were designed for humans clicking through login screens -- not for autonomous software that decides what to do next based on context. When something can act, it needs an identity. And identity is how we enforce access control and maintain accountability. The challenge is that we now have three identity categories -- human, machine, and agent -- and they need a unified framework. Transition: What does that framework look like? (~1.5 min)

---

## The AI Agent Identity Lifecycle

```
+---------------------+       +----------------------------+
|  1. PROVISIONING    | ----> |  2. AUTHORIZATION &        |
|                     |       |     SCOPING                |
|  Assign unique,     |       |  Define least-privilege    |
|  policy-bound       |       |  access: task-specific     |
|  identity to        |       |  and time-bound            |
|  verified agent     |       |                            |
+---------------------+       +----------------------------+
         ^                                  |
         |                                  v
+---------------------+       +----------------------------+
|  4. DEPROVISIONING  | <---- |  3. RUNTIME ENFORCEMENT    |
|                     |       |                            |
|  Revoke access,     |       |  Monitor agent behavior    |
|  invalidate creds,  |       |  to ensure it stays within |
|  preserve evidence  |       |  granted permissions       |
+---------------------+       +----------------------------+
```

**"AI agent identity must be task- and time-bound. Treating identity as a lifecycle prevents standing access from persisting after work ends."**

> **Speaker notes:** Identity is not a one-time event. It is a lifecycle with four phases. First, provision a unique identity tied to policy. Second, scope that identity to the specific task with time bounds. Third, enforce those boundaries at runtime. Fourth, deprovision -- revoke credentials, clean up access, and keep the audit trail. The critical insight is that every phase must be automated. Manual lifecycle management does not scale to 144 non-human identities per human. Transition: Where does your organization fall on this spectrum? (~1.5 min)

---

## The 4-Stage Maturity Model

| Stage | Approach | Description |
|-------|----------|-------------|
| **1. Static Secrets** | Hardcoded credentials | Secrets in source code, config files, basic vault stores. **Where most organizations are today.** |
| **2. Auto-Rotation** | Periodic rotation | Automate periodic rotation of credentials and API keys |
| **3. Dynamic Identities** | Zero Standing Privileges | Auto-creation and deletion of temporary identities only when required |
| **4. Secretless** | SSO for Machines | OAuth, OIDC, SPIFFE, and ZSP -- advanced authentication enabling identity-based access with no secrets to steal |

**"AI agents are the forcing function that pushes organizations from Stage 1 to Stage 4."**

> **Speaker notes:** Most organizations are at Stage 1 or early Stage 2. Static secrets in config files, maybe some basic rotation. AI agents break this model because they operate at machine speed, across systems, with dynamic tool selection. You cannot manually manage secrets for agents that spin up, act, and disappear. AI agents are the forcing function that compels the move to Stage 4 -- secretless, identity-based access where there are simply no secrets to steal. Transition: This is exactly what Akeyless was built to deliver. (~1.5 min)

---

## Akeyless: Identity Security for AI Agents

| Capability | What It Does |
|------------|-------------|
| **SecretlessAI** | JIT identity-based authentication -- no embedded secrets |
| **AI Agent Identity Provider** | Verifiable, federated identities for agents |
| **Universal Identity** | Solves the secret zero problem with child token hierarchies and auto-rotation |
| **Dynamic Secrets** | Ephemeral credentials with TTL for databases, cloud providers, and SaaS |
| **AI Insights** | AI-powered anomaly detection, audit trails, and automated remediation |
| **MCP Integration** | Native `akeyless mcp` command for AI tools -- Claude Code, Cursor, VS Code, Copilot |

> **Speaker notes:** Six capabilities that map directly to the lifecycle and maturity model we just discussed. SecretlessAI eliminates embedded secrets entirely. The Agent Identity Provider gives every agent a verifiable identity. Universal Identity solves the bootstrapping problem -- secret zero. Dynamic Secrets ensure every credential is ephemeral with a TTL. AI Insights provides continuous monitoring. And MCP Integration means this works natively with the AI tools your developers are already using. Transition: Let me show you how these pieces fit together architecturally. (~1.5 min)

---

## Architecture: Secretless Dynamic Access

```
+-------------------------+
|   AI Agent              |
|   (Claude Code)         |
+------------+------------+
             |
             | MCP Protocol
             v
+-------------------------+
|   Akeyless MCP Server   |
+------------+------------+
             |
             | Secure Connection
             | (Universal Identity)
             v
+-------------------------+
|   Akeyless Platform     |
+------------+------------+
             |
             | Dynamic Secret
             | (Credential Retrieval)
             v
+---+---+---+---+---+---+
| MySQL | AWS | Azure | Slack | Salesforce | ServiceNow |
+---+---+---+---+---+---+
```

**No secrets in agent code. No standing privileges. Full audit trail.**

1. The agent **proves identity** via Universal Identity
2. Akeyless **evaluates policy** against the request
3. A **short-lived credential** is issued for the target system
4. The credential **auto-expires** after the TTL

> **Speaker notes:** Here is the full flow. The AI agent -- in this case Claude Code -- communicates via MCP protocol to the Akeyless MCP Server. The server authenticates using Universal Identity, no secret zero problem. Akeyless evaluates policy, then issues a dynamic, short-lived credential for the specific target system. That credential auto-expires. At no point does the agent hold a permanent secret. At every point, the action is audited. Transition: Now let me set up what you are about to see live. (~1.5 min)

---

## Transition to Demo

| Before (Stage 1) | After (Stage 4) |
|---|---|
| Hardcoded password in Python script | Akeyless MCP + Universal Identity |
| Permanent database access | Dynamic credential with 5-min TTL |
| Credentials in git history | No secrets to leak |
| No audit trail | Full audit of every access |
| Manual revocation | Auto-expires, zero cleanup |

**"We are going from Stage 1 -- static secrets in code -- straight to Stage 4 -- secretless, identity-based access."**

**Watch the split screen.**

> **Speaker notes:** Here is what we are about to demonstrate. On one side, the before: a Python script with a hardcoded MySQL password -- permanent access, credentials sitting in git history. On the other side, the after: Akeyless MCP with Universal Identity, a dynamic credential that lives for five minutes and auto-expires. Same database, same query, fundamentally different security posture. Watch the split screen -- you will see both approaches side by side. Transition to demo. (~1 min)

---

## Get Started with Secretless AI

### Resources

- **Akeyless MCP Server docs**
  [docs.akeyless.io/docs/mcp-server](https://docs.akeyless.io/docs/mcp-server)

- **AI Agent Identity Security Deployment Guide**
  PDF download available at the session link

- **Request a demo**
  [akeyless.io/demo](https://akeyless.io/demo)

- **Documentation**
  - Universal Identity: [docs.akeyless.io/docs/universal-identity](https://docs.akeyless.io/docs/universal-identity)
  - Dynamic Secrets: [docs.akeyless.io/docs/dynamic-secrets](https://docs.akeyless.io/docs/dynamic-secrets)

> **Speaker notes:** This slide stays up during Q&A and after the session. Point attendees to the MCP Server docs to get started immediately, the deployment guide PDF for a structured rollout plan, and the demo request page if they want a tailored walkthrough. Thank everyone for their time and open the floor to questions. (~30 sec, then Q&A)
