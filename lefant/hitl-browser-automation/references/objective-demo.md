# Objective Demo

Use this when the user wants the agent to infer or continue from a human smoke-app demonstration.

The user must state the objective in the prompt. Do not assume every demonstration means “generate a script” or “recover the exact sequence.” Common objectives:

- report the exact visible click sequence
- reproduce the same final state
- generate an `agent-browser` replay script or command outline
- continue automation from the demonstrated state
- explain what evidence is missing and what the human should repeat

## Demo flow

1. Start the hub from the target project/context directory:

   ```bash
   hitl-browser-hub start
   ```

2. Give the human the VNC forwarding and connection details printed by startup.
3. Ask the human to use the smoke app's objective demo buttons. Example prompt:

   ```text
   Please click a short sequence of Red, Blue, and Green buttons in the VNC browser, then tell me when done. I will use the captured evidence to answer your objective.
   ```

4. Capture a checkpoint after the human finishes:

   ```bash
   hitl-browser-hub screenshot objective-demo
   ```

5. Inspect artifact paths:

   ```bash
   hitl-browser-hub paths
   ```

6. Use the user's objective to decide what to inspect:

   - For click sequence: inspect network entries for `/api/click` request post bodies and screenshots.
   - For final state: inspect `/api/state`, latest `/api/click` response bodies, and screenshots.
   - For replay: derive only the minimal actions supported by visible state and recorded requests.
   - For continuation: confirm the current browser/session state before acting.

7. Stop the hub when done:

   ```bash
   hitl-browser-hub stop
   ```

## Evidence rules

- Prefer evidence from recorded requests, response bodies, metadata, and screenshots over human narration.
- If evidence is incomplete, say what is missing. Do not fabricate exact sequences from final state alone.
- Treat raw artifacts as sensitive. Do not paste whole HAR files, screenshots, browser profiles, cookies, tokens, or session data into chat.
- Summarize only the minimum safe evidence needed to answer the objective.

## Example objective responses

Sequence objective:

```text
The captured evidence supports this sequence: red → blue → green. Evidence: three `/api/click` requests with matching `choice` values and final smoke-app state count 3.
```

Replay objective:

```text
A replay should click Red, then Blue, then Green, then verify the flow status contains `red → blue → green`. I can generate a replay script from that supported sequence.
```

Insufficient evidence:

```text
I can see the final state is `green`, but the artifact set does not include enough request history to prove the full sequence. Please repeat the demo after I restart recording or capture a checkpoint.
```
