# Demonstration Handoff

Use when the human will show a browser workflow once and the agent should learn, inspect, or replay it.

## Flow

1. Run prerequisite checks.
2. Start the hub with the smoke app or target URL.
3. Give the human VNC instructions from startup output.
4. Ask the human to demonstrate the workflow in the VNC browser.
5. Capture checkpoints around important states:

   ```bash
   hitl-browser-hub screenshot before-submit
   hitl-browser-hub screenshot after-submit
   ```

6. Inspect artifacts with `hitl-browser-hub paths`.
7. Use `agent-browser` for replay or continuation when safe.
8. Stop the hub.

## What to preserve

- visible action sequence
- endpoint paths and methods
- status codes
- sanitized request/response shapes
- screenshots that do not reveal secrets
- omission reasons for missing bodies
- replay result

## Avoid

- asking the human to narrate every DOM detail when captured evidence exists
- committing raw traces or screenshots
- treating shared-session attach as required; separate-context replay is the default
