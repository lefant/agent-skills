# Proof: WebUntis message and timetable access

## Question

Can we log into a WebUntis tenant with credentials stored in `~/.env.webuntis`, read the inbox, fetch the newest full message, and resolve a guardian-visible student timetable?

## Status

proved

## Scripts

- `scripts/read-latest-message.py` - Logs in via JSON-RPC, mints a JWT, fetches the inbox, fetches the newest full message, and prints the result.
- `scripts/read-timetable.py` - Logs in as the guardian, resolves the dependent student from the timetable menu, and prints the week timetable around a given date. It can also print a teacher code-to-name mapping for that week.

## Auth dependency

By default the scripts read `~/.env.webuntis`.

Preferred credential convention:

```bash
WEBUNTIS_USERNAME=user@example.com
WEBUNTIS_PASSWORD=...
```

Quoted values also work:

```bash
WEBUNTIS_USERNAME='user@example.com'
WEBUNTIS_PASSWORD='...'
```

Tenant-specific values should be provided locally, not committed to this skill:

```bash
WEBUNTIS_HOST=<server>.webuntis.com
WEBUNTIS_SCHOOL=<school-name>
WEBUNTIS_CLIENT_ID=webuntis-proof
WEBUNTIS_ENV_FILE=/custom/path/.env.webuntis
WEBUNTIS_STUDENT_ID=<student-id>
```

Notes:
- Runtime dependency: `python` only. The scripts use the Python standard library and do not require extra packages.
- The scripts do **not** persist the password anywhere else.
- They perform a fresh login each run.
- They mint a fresh JWT each run.
- They do **not** cache `JSESSIONID` or JWT on disk.
- This bundled proof intentionally excludes live account identifiers and personal timetable data.

## Exact API sequences proved

### Message script

1. `POST /WebUntis/jsonrpc.do?school=<school-name>` with `authenticate`
2. Build cookies from the returned `sessionId`:
   - `JSESSIONID=<sessionId>`
   - `schoolname=_<base64-school-name>`
3. `GET /WebUntis/api/token/new`
4. `GET /WebUntis/api/rest/view/v1/messages`
5. `GET /WebUntis/api/rest/view/v1/messages/{id}`

### Timetable script

1. `POST /WebUntis/jsonrpc.do?school=<school-name>` with `authenticate`
2. Build cookies from the returned `sessionId`:
   - `JSESSIONID=<sessionId>`
   - `schoolname=_<base64-school-name>`
3. `GET /WebUntis/api/token/new`
4. `GET /WebUntis/api/rest/view/v1/timetable/menu`
5. choose a dependent student id from `dependents[]`
6. `GET /WebUntis/api/rest/view/v1/timetable/entries?start=...&end=...&resourceType=STUDENT&resources=<studentId>`

The proof intentionally uses `/WebUntis/api/...` routes because those were the working authenticated endpoints on the live tenant.

## Run

```bash
python lefant/untis-access/scripts/read-latest-message.py --host <server>.webuntis.com --school <school-name>
python lefant/untis-access/scripts/read-timetable.py --host <server>.webuntis.com --school <school-name> --date 2026-04-13
python lefant/untis-access/scripts/read-timetable.py --host <server>.webuntis.com --school <school-name> --date 2026-04-13 --teachers
```

## Result

The proof succeeded.

It was able to:
- authenticate against the target WebUntis tenant
- read the inbox list
- select the newest message by `sentDateTime`
- fetch the full message body by id
- resolve guardian-visible dependents
- fetch weekly timetable entries for a selected dependent student

It also established:
- the local JS repo already supports inbox preview retrieval but not full message-detail helpers
- the local Python repo does not implement message-center access
- JWT lifetime is about 15 minutes, so fresh minting per run is the right pattern
- guardian timetable access should use the newer timetable menu + entries REST flow rather than old JSON-RPC timetable element assumptions
