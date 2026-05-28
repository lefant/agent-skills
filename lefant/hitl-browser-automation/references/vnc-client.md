# VNC Client Guidance

Browser Debug Hub uses classic VNC for human-visible browser access.

## Local machine

If the hub is running on the same machine as the human's VNC client, connect to the VNC endpoint printed by startup:

```text
127.0.0.1:<vnc-port>
```

Use a dedicated VNC client such as TigerVNC Viewer or RealVNC Viewer when possible.

## Remote machine

VNC binds to `127.0.0.1` on the remote host. Use local forwarding from the human workstation:

```bash
ssh -L <vnc-port>:127.0.0.1:<vnc-port> \
    -L <cdp-port>:127.0.0.1:<cdp-port> \
    user@remote-host
```

Then connect the VNC client to:

```text
127.0.0.1:<vnc-port>
```

Forward CDP only when the agent or local tooling needs it. CDP exposes programmatic browser control and browser data.

## macOS fallback

macOS Screen Sharing can sometimes connect to VNC servers:

```text
vnc://127.0.0.1:<vnc-port>
```

If Screen Sharing refuses the connection or behaves poorly, use a dedicated VNC client.

## Safety model

- VNC stays loopback-only by default.
- SSH local forwarding or equivalent secure tunneling is the access boundary.
- VNC password support is optional defense-in-depth, not the primary boundary.
- Do not expose VNC or CDP on public interfaces.
