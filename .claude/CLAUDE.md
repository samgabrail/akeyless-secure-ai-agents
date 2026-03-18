# Akeyless Secure AI Agents Demo

## Akeyless CLI

- The correct command for dynamic secrets is: `akeyless dynamic-secret get-value`
- Do NOT use `get-dynamic-secret-value` -- that command doesn't exist
- Do NOT use `--profile demo` -- we must authenticate via Universal Identity so the audit trail shows the AI agent identity

## Retrieving dynamic MySQL credentials

Always authenticate with the UID token from `.mcp.json`. Extract it and use it:

```bash
akeyless dynamic-secret get-value \
  --name /demo-ai-agents/mysql-dynamic-secret \
  --uid-token "$(python3 -c "import json; args=json.load(open('.mcp.json'))['mcpServers']['akeyless']['args']; print(args[args.index('--uid-token')+1])")" \
  --json
```

This returns JSON with `user`, `password`, `ttl_in_minutes`, and `id` fields.

## Connecting to MySQL

- MySQL is accessible at `127.0.0.1:3306` via kubectl port-forward
- There is NO mysql CLI client installed
- Use `app/secure_query.py` to query with dynamic credentials:

```bash
python3 app/secure_query.py \
  --user "<dynamic_user>" \
  --password "<dynamic_password>" \
  --query "SELECT company_name, contact_name, contract_tier, annual_revenue FROM customers WHERE annual_revenue > 5000000 ORDER BY annual_revenue DESC"
```

- The database name is `demo`
- The main table is `customers` with columns: id, company_name, contact_name, email, contract_tier, annual_revenue, region, created_at
- Do NOT use `app/insecure_query.py` -- that is the "old way" demo with hardcoded credentials

## MCP Server Limitations

The Akeyless MCP server can list and describe items but cannot retrieve secret values or generate dynamic secrets. Use the CLI (with UID token) for credential retrieval.
