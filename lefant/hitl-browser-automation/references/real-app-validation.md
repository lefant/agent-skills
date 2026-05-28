# Real-App Validation

Run real-app validation only after the smoke flow passes.

## Preconditions

- `hitl-browser-hub check` passes.
- The hub can start and stop cleanly.
- The smoke app can be shown through VNC.
- Trace artifacts include screenshots and network evidence.
- `hitl-browser-hub replay-smoke` succeeds or produces a clear limitation.

## Target selection

Use a safe target application and account:

- prefer sandbox/test accounts
- avoid production data
- avoid irreversible actions
- keep credentials out of tracked files and chat
- keep raw artifacts untracked

## Flow

1. Start the hub with the real-app URL:

   ```bash
   hitl-browser-hub start --url 'https://example.test/'
   ```

2. Connect through VNC.
3. Complete the demonstration, verification, or credential handoff flow.
4. Capture checkpoints around important states when safe.
5. Inspect artifacts with the coding agent.
6. Attempt `agent-browser` replay or continuation when safe.
7. Stop the hub.
8. Preserve only sanitized notes if the result should be durable.

## Suggested sanitized note

```markdown
# HITL browser validation

## Target

- App:
- Account/sandbox:

## Flow

1.
2.
3.

## Evidence reviewed

- Trace path, local/untracked:
- Sanitized requests:
- Screenshots reviewed:
- Omission notes:

## Replay or continuation result

- Result:
- Limitation:

## Conclusion

- Continue / change direction / stop:
- Follow-ups:
```
