# Verification Handoff

Use when the agent can drive the browser but needs a human to inspect or approve the result before continuing.

## Flow

1. Run prerequisite checks.
2. Start the hub with the target app or recreate the state in the hub browser.
3. Run the safe automation steps or prepare the browser state.
4. Ask the human to connect over VNC and inspect the result.
5. Capture a checkpoint if the verification result matters later:

   ```bash
   hitl-browser-hub screenshot human-verified
   ```

6. Continue only after the human confirms the result or gives correction.
7. Stop the hub when the checkpoint is complete.

## Good verification prompts

- "Please confirm this is the expected account/page/state before I submit."
- "Please check the generated form values. I will wait before clicking the final button."
- "Please verify the visual result matches your expectation."

## Safety

If the next action is irreversible, payment-like, destructive, or changes production data, pause for explicit approval. Do not infer approval from silence.
