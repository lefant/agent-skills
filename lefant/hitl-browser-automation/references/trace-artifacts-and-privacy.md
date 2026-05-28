# Trace Artifacts and Privacy

The hub can produce browser profiles, screenshots, HAR-like network records, raw CDP events, metadata, and logs. Treat all raw artifacts as sensitive.

## Common artifact paths

Use:

```bash
hitl-browser-hub paths
```

Typical artifact types:

- `network.har.json` — HAR-like request/response evidence
- `events.jsonl` — CDP event stream
- `metadata.json` — trace metadata, screenshots, omissions
- `summary.md` — short agent-readable summary
- `screenshots/*.png` — captured screenshots
- `agent-browser-replay.txt` — replay result when smoke replay runs
- `shared-session-test.md` — shared-session experiment result

## Never commit or paste raw secrets

Redact before sharing or preserving:

- cookies
- bearer tokens
- API keys
- CSRF/XSRF values
- session ids
- client secrets
- passwords or MFA codes
- personal data
- production tenant ids unless explicitly safe
- screenshots containing secrets or private data

## Usually safe to preserve after review

- endpoint paths
- HTTP methods
- status codes
- sanitized request payload shape
- sanitized response payload shape
- visible UI action sequence
- omission reasons
- replay result
- smoke-app objective summary, such as `red -> blue -> green`, when it contains no private data

## Omission reasons

Some response bodies may be unavailable because they are cached, binary, failed, cross-origin restricted, or inaccessible via CDP. The recorder should preserve omission reasons rather than silently hiding missing evidence.

For prompt-directed objectives, do not infer more than the artifacts support. A final visible state may prove the outcome without proving the full click sequence.
