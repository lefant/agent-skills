# Credential Handoff

Use when login, MFA, consent, or another sensitive step should be completed by the human in the browser.

## Core rule

The human enters secrets directly in the VNC browser. The agent must not ask the user to paste passwords, MFA codes, cookies, bearer tokens, session ids, API keys, or recovery codes into chat.

## Flow

1. Run prerequisite checks.
2. Start the hub with the login or target URL:

   ```bash
   hitl-browser-hub start --url 'https://example.test/login'
   ```

3. Give the human the VNC connection instructions.
4. Tell the human to complete login/MFA/consent directly in the browser.
5. Wait for the human to say the session is ready.
6. Capture a checkpoint only if it will not expose secrets or private data.
7. Resume automation with `agent-browser` or CDP evidence.
8. Stop the hub when work is done.

## What not to capture or share

- passwords
- MFA codes
- cookies
- bearer tokens
- CSRF/XSRF values
- session ids
- screenshots showing secrets or private data

## If login fails

Ask the human to retry in the VNC browser or report the visible error in their own words. Do not request raw credential material.
