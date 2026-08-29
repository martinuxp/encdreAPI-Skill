# ChatGPT cloud setup

Use the remote MCP server instead of a Custom GPT Action:

```text
https://prod.encuadre.muxp.art/mcp
```

The connector advertises OAuth metadata at:

```text
https://prod.encuadre.muxp.art/.well-known/oauth-protected-resource/mcp
```

ChatGPT starts OAuth automatically. The user is sent to `prod.encuadre.muxp.art`, signs in with their Encuadre Clerk account, and explicitly approves the connection. The callback and PKCE verifier remain inside ChatGPT. Do not copy them into a prompt or ask a user to handle them.

Access is limited to `projects:read` and `contacts:read`. The opaque bearer token expires after 30 minutes and the server does not issue a refresh token; connecting again is required after expiry.

Current MCP tools:

- `list_projects(search?, includeArchived?)`
- `get_project(id)`
- `get_project_context(id)`
- `list_contacts(search?)`
- `get_contact(id)`

The REST OpenAPI contract remains available for runtimes that can keep private state and need writes. It is not the preferred path for a normal ChatGPT cloud chat.
