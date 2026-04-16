# Auth and environment convention

## Default credential file

The bundled Untis proof scripts read credentials from:

```text
~/.env.webuntis
```

## Credential convention

Use this exact convention by default:

```bash
WEBUNTIS_USERNAME=user@example.com
WEBUNTIS_PASSWORD=...
```

Notes:
- `WEBUNTIS_PASSWORD` is required but should not be printed in logs.
- The scripts accept both unquoted and quoted values.
- Prefer the unquoted convention above unless the value contains characters that need shell quoting.

Quoted form also works:

```bash
WEBUNTIS_USERNAME='user@example.com'
WEBUNTIS_PASSWORD='...'
```

## Required local completeness check

Before running the bundled scripts, confirm these four values are available either in `~/.env.webuntis`, via process environment, or via CLI flags:

```bash
WEBUNTIS_USERNAME=user@example.com
WEBUNTIS_PASSWORD=...
WEBUNTIS_HOST=<server>.webuntis.com
WEBUNTIS_SCHOOL=<school-name>
```

If `WEBUNTIS_HOST` or `WEBUNTIS_SCHOOL` is missing, stop and check the user's local setup notes before running the scripts.

## Optional overrides

The scripts also support these optional variables:

```bash
WEBUNTIS_HOST=<server>.webuntis.com
WEBUNTIS_SCHOOL=<school-name>
WEBUNTIS_CLIENT_ID=webuntis-proof
WEBUNTIS_ENV_FILE=/custom/path/.env.webuntis
WEBUNTIS_STUDENT_ID=<student-id>
```

## Auth behavior

Default auth flow:
1. `POST /WebUntis/jsonrpc.do?school=...` with `authenticate`
2. build `JSESSIONID` + `schoolname` cookie header
3. `GET /WebUntis/api/token/new`
4. use bearer token for `/WebUntis/api/...` requests

## Operational guidance

- Mint a fresh JWT every run.
- For unattended jobs, fresh login per run is safer than attempting to reuse `JSESSIONID`.
- Do not persist derived JWTs in this skill; the scripts intentionally avoid writing token caches.
