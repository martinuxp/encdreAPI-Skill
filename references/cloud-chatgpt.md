# ChatGPT cloud setup

A standard ChatGPT conversation needs an Action, app, or compatible HTTPS connector before it can call this API. Do not ask the user for an API key: there is none.

For a Custom GPT Action:

1. Import the Encuadre OpenAPI contract.
2. Select **None** for Action authentication. The API connection is authorized by the Clerk approval link, not by ChatGPT configuration.
3. Allow the `prod.encuadre.muxp.art` domain in the workspace when applicable.
4. Test the connection flow in Action preview.

Cloud execution state is private to the tool runtime:

- Start: retain `requestId` and `exchangeSecret`; show only `authUrl`.
- Approved: exchange once and retain `sessionToken` with its expiry.
- Requests: send `X-Encuadre-Session`.
- Expired: discard the values and start a new connection.

Never put the exchange secret or session in user-visible messages, custom instructions, Action authentication settings, or persistent storage. A runtime that cannot preserve private state cannot safely perform calls after the approval step; use a stateful connector or OAuth bridge instead.
