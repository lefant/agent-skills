---
name: hitl-browser-automation
description: Use when browser automation needs a human checkpoint: the user wants to demonstrate a workflow once, watch and verify an agent-driven browser result before proceeding, log in or complete MFA/credential-sensitive steps manually, connect through VNC, or use agent-browser with human-in-the-loop browser control. This skill sets up and operates the bundled Browser Debug Hub runtime with safe loopback VNC/CDP defaults.
---

# HITL Browser Automation

Use this skill when `agent-browser` automation needs a human in the loop for demonstration, verification, or credential handoff.

Do not use this skill for ordinary browser automation with no human checkpoint. Use the normal browser automation skill instead.

## Default Workflow

1. Classify the handoff mode:
   - human demonstrates a flow -> `references/demonstration-handoff.md`
   - agent runs automation and human verifies -> `references/verification-handoff.md`
   - human logs in, completes MFA, or handles sensitive entry -> `references/credential-handoff.md`
2. Check prerequisites before startup:

   ```bash
   hitl-browser-hub check
   ```

   If checks fail, read `references/prerequisites.md` and report the missing tools.
3. Start the hub from the target project/context directory. If the command is not on PATH, invoke the skill-owned script by path; do not `cd` into the skill package for normal operation because runtime state is keyed from the current working directory.

   ```bash
   hitl-browser-hub start
   ```

   For a specific target app:

   ```bash
   hitl-browser-hub start --url 'https://example.test/'
   ```

   If the command is not installed on PATH:

   ```bash
   /path/to/hitl-browser-automation/scripts/hitl-browser-hub start --url 'https://example.test/'
   ```

4. Give the human the VNC connection instructions printed by startup. For remote machines, use explicit local forwarding. Read `references/vnc-client.md` if connection details matter.
5. Let the human act in the VNC browser for the selected handoff mode.
6. Capture checkpoints around important states when useful:

   ```bash
   hitl-browser-hub screenshot after-login
   ```

7. Resume automation or inspection with `agent-browser` and captured evidence. Use the user's prompt as the objective: report the click sequence, reproduce the final state, generate a replay script, continue automation, or state what evidence is missing. Read `references/objective-demo.md` for the smoke-app objective demo. For smoke validation:

   ```bash
   hitl-browser-hub replay-smoke
   ```

8. Inspect paths/artifacts only as needed:

   ```bash
   hitl-browser-hub paths
   ```

   Read `references/trace-artifacts-and-privacy.md` before copying, committing, or pasting artifacts.
9. Stop the hub when done:

   ```bash
   hitl-browser-hub stop
   ```

## Safety Boundaries

- VNC and CDP must stay loopback-only by default.
- Use SSH local forwarding or an equivalent secure tunnel for remote access.
- Raw browser profiles, traces, screenshots, cookies, and logs can contain secrets. Do not commit them.
- For credential handoff, the human enters secrets directly in the browser. Do not ask the user to paste passwords, MFA codes, cookies, bearer tokens, or session data into chat.
- Run smoke validation before using a real app when the environment is new or uncertain.

## Commands

Run normal workflow commands from the target project/context directory. Toolnix or another installer may put `hitl-browser-hub` on PATH. If not, invoke `scripts/hitl-browser-hub` by path from the skill package.

```bash
hitl-browser-hub check [--json]
hitl-browser-hub start [--url URL] [--no-smoke-app]
hitl-browser-hub status [--json]
hitl-browser-hub paths
hitl-browser-hub screenshot [label]
hitl-browser-hub replay-smoke
hitl-browser-hub shared-session-test
hitl-browser-hub stop
```

Run package validation from the skill root:

```bash
./scripts/validate-package.sh
```

Runtime state defaults outside the skill package under the user state directory. Override with `BDH_STATE_ROOT` for isolated test runs.

## Read On Demand

- `references/prerequisites.md` when setup fails or the environment is unknown.
- `references/demonstration-handoff.md` when the human will show the workflow first.
- `references/verification-handoff.md` when the human needs to approve or inspect an agent-driven result.
- `references/credential-handoff.md` when login, MFA, or other secrets are involved.
- `references/vnc-client.md` when the human needs connection instructions.
- `references/trace-artifacts-and-privacy.md` before sharing or preserving artifacts.
- `references/real-app-validation.md` before using the hub against a non-smoke target.
- `references/objective-demo.md` when the user wants the agent to infer a click sequence, reproduce an outcome, generate a replay script, or continue automation from smoke-app evidence.

## Validation

Static package check:

```bash
./scripts/validate-package.sh
```

Runtime checks:

```bash
hitl-browser-hub check --json
./scripts/browser-debug-hub/tests/smoke-app.test.sh
./scripts/browser-debug-hub/tests/launcher-safety.test.sh
```

The launcher safety test exercises full startup only when prerequisites are present; otherwise it verifies that prerequisite detection reports missing tools cleanly.
