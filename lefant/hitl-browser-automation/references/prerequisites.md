# Prerequisites

Run from the skill root:

```bash
hitl-browser-hub check
hitl-browser-hub check --json
```

Required runtime tools:

- Chromium or Google Chrome
- Node.js
- `jq`
- `python3`
- `agent-browser`
- a VNC/display stack

Preferred VNC/display stack:

1. `Xtigervnc` or `Xvnc` from TigerVNC
2. fallback: `Xvfb` plus `x11vnc`

Optional window managers detected when present:

- `fluxbox`
- `openbox`
- `twm`

## Browser discovery

The runtime checks common environment variables first, then PATH:

- `BDH_CHROMIUM`
- `TOOLNIX_CHROMIUM`
- `CHROMIUM_BIN`
- `CHROME_BIN`
- `AGENT_BROWSER_EXECUTABLE_PATH`
- `PUPPETEER_EXECUTABLE_PATH`
- `chromium`, `google-chrome-stable`, or `google-chrome`

## Failure handling

If `check` reports missing tools, do not start the hub. Report the missing prerequisite and ask the environment owner to install or configure it.

Do not silently replace real browser automation with a text-only fetch when the task needs visible browser state, VNC verification, or `agent-browser` replay.
