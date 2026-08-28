---
name: encuadre-production-api
description: Use the Encuadre production portal API to safely read and modify production projects, contacts, people, files, and audit-relevant data through the deployed REST API.
---

# Encuadre Production API

Use this skill whenever an agent needs to interact with the Encuadre production portal rather than Firebase directly.

## Non-negotiable boundaries

- Base URL: `https://prod.encuadre.muxp.art/api`.
- Never connect an agent directly to Firestore, Storage, Clerk Admin APIs, or Firebase Admin SDK. Use the REST API only.
- Never put `PRODUCTION_API_TOKEN` or `CLERK_SECRET_KEY` in frontend code, prompts, logs, tool output, commits, or chat messages.
- Treat contact data, project data, notes, phone numbers, emails, and media references as internal production information.
- Do not invent Firestore paths, fields, roles, or endpoints. Use only the contract in `references/api-reference.md`.
- Do not send arbitrary Firestore documents. Every write must use an explicit endpoint and validated fields.
- Ask for user confirmation before a consequential write when the user has not clearly requested it. A `DELETE` is always soft delete, but still requires recent user authentication.

## Authentication selection

Use one of these server-side credentials:

1. Agent integration: `X-API-Key: <PRODUCTION_API_TOKEN>`.
2. Internal web/user session: `Authorization: Bearer <Clerk session token>`.

Read operations can use either. Create operations can use the agent token or a Clerk session. Updates, person associations, photo uploads, and deletes require a recent authorization grant in addition to the credential. Never ask the user to paste the API key into a browser.

## Standard tool contract

Expose or emulate these agent tools using HTTP calls described in the reference:

- `list_projects(search?, includeArchived?)`
- `get_project(id)`
- `get_project_context(id)`
- `search_contacts(query)`
- `list_contacts(search?)`
- `get_contact(id)`
- `create_project(data)`
- `update_project(id, data)`
- `create_contact(data)`
- `update_contact(id, data)`
- `list_project_people(projectId)`
- `add_person_to_project(projectId, type, person)`
- `update_project_person(projectId, personId, type, updates)`
- `remove_person_from_project(projectId, personId, type)`
- `upload_contact_photo(contactId, contentBase64, mimeType)`
- `delete_project(id)`
- `delete_contact(id)`

Read `references/api-reference.md` before using a tool that writes, deletes, uploads, or handles a new resource type. Read `references/security-and-workflow.md` whenever a request returns `AUTH_REQUIRED`, `INVALID_GRANT`, or involves a destructive/sensitive action.

## Required response behavior

- Preserve the API's structured error fields: `error`, `message`, and any `authUrl`/`expiresAt`.
- If the API returns `AUTH_REQUIRED`, show the user the returned `authUrl`, explain that it is a short-lived Clerk reauthentication link, and wait for the user to complete it before retrying the exact same operation.
- Retry only with the returned `grantId`, never with a guessed, reused, or client-invented grant.
- Report the resulting resource ID and operation outcome, but do not echo credentials or complete tokens.
- If a requested operation is not in the contract, state that it is not currently exposed by the API instead of falling back to direct Firebase access.
