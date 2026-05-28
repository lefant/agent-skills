# HITL Browser Automation Skill

Self-contained Claude-style skill for browser automation that needs a human checkpoint: demonstration, verification, or credential handoff.

The skill bundles Browser Debug Hub as its runtime mechanism. It provides:

- launcher-managed Chromium/Chrome session
- VNC access for the human operator
- loopback-only CDP for evidence capture
- HAR-like network artifacts and screenshots
- a controlled smoke app
- `agent-browser` replay validation
- references for safe real-app use

## Package layout

```text
hitl-browser-automation/
├── SKILL.md
├── scripts/
│   ├── hitl-browser-hub
│   ├── validate-package.sh
│   └── browser-debug-hub/
├── references/
└── evals/
```

## Quick start

From the target project or working directory, use the installed command when available:

```bash
hitl-browser-hub check
hitl-browser-hub start
hitl-browser-hub status
hitl-browser-hub stop
```

If the command is not on PATH, invoke the skill-owned script by path while keeping your current directory at the target project:

```bash
/path/to/hitl-browser-automation/scripts/hitl-browser-hub check
/path/to/hitl-browser-automation/scripts/hitl-browser-hub start --url 'https://example.test/'
```

Use `hitl-browser-hub start --url 'https://example.test/'` for a target app.

## Runtime state

The wrapper keeps state outside the skill package by default:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/hitl-browser-automation/<project-name>-<hash>/
```

Override with `BDH_STATE_ROOT` for tests or controlled runs.

## Safety

- VNC and CDP bind to `127.0.0.1` by default.
- Remote use requires explicit local forwarding or equivalent safe tunnel.
- Profiles, traces, screenshots, cookies, and logs are sensitive. Do not commit raw artifacts.
- Credential handoff means the human enters secrets directly in the browser; agents must not ask for secrets in chat.

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
