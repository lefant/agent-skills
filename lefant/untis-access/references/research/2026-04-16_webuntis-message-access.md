# WebUntis message access research

Date: 2026-04-16

## Goal

Determine which local WebUntis-related repo can access WebUntis messages for a live tenant, identify the working authenticated API flow, and capture runnable proofs. This bundled copy intentionally redacts live account, tenant, and timetable identities.

## Repository overview

| Repo | Location | Language | Auth model | Timetable | Homework | Messages | Notes |
|---|---|---|---|---|---|---|---|
| `SchoolUtils/WebUntis` | `/home/exedev/git/external/WebUntis` | TypeScript | JSON-RPC login + `/WebUntis/api/token/new` JWT | Yes | Yes | Partial inbox support | Closest local repo to the working tenant flow; lacks full message-detail helpers. |
| `python-webuntis` | `/home/exedev/git/external/python-webuntis` | Python | JSON-RPC session cookie | Yes | Not found in current docs beyond core JSON-RPC set | No message-center support found | Good for classic JSON-RPC entities, not useful for inbox/messages. |
| `xp4u1/untis` | `/home/exedev/git/external/untis` | Elixir | Mobile-style JSON-RPC with shared-secret TOTP | Yes | Yes | Only “messages of the day” style method, not inbox | Interesting because it uses `getAppSharedSecret` and OTP instead of keeping the password around. |
| `kaiser-jan/scriptable-untis` | `~/.cache/checkouts/github.com/kaiser-jan/scriptable-untis` | TypeScript | Form login (`j_spring_security_check`) + `/WebUntis/api/token/new` JWT | Yes | No homework flow found in reviewed files | No inbox flow found | Strong reference for modern timetable/exams/grades calls against `/WebUntis/api/...`. |

## Repos examined

### 1. `/home/exedev/git/external/WebUntis`

Node/TypeScript wrapper around WebUntis JSON-RPC plus a few REST helpers.

Relevant files:
- `src/base.ts`
- `src/types.ts`
- `Readme.md`
- generated docs under `docs/`

#### What it implements

The repo already contains partial message-center support:

- `Base.login()` uses JSON-RPC `authenticate` against `/WebUntis/jsonrpc.do?school=...`
- `Base._getJWT()` calls `GET /WebUntis/api/token/new`
- `Base.getInbox()` calls `GET /WebUntis/api/rest/view/v1/messages`
- `Inbox` and `Inboxmessage` types exist in `src/types.ts`

`Inboxmessage` only models inbox-list preview fields:
- `id`
- `subject`
- `contentPreview`
- `sender`
- `sentDateTime`
- flags like `isMessageRead`, `isReplyAllowed`

#### What is missing

The repo does **not** expose typed helpers for full message-center operations that were proven live on the tenant:

- fetch full incoming message by id
- fetch sent message by id
- fetch draft by id
- read-confirmation
- reply / reply-form
- attachments

So this repo is close, but incomplete for full message reading workflows.

#### Important correction

Initial inspection of the SPA bundle suggested message routes like `/api/rest/view/v1/messages`. That was misleading without the runtime base URL. On the actual tenant, the working authenticated endpoints were under `/WebUntis/api/...`, not bare `/api/...`.

Observed behavior:
- `GET https://<server>.webuntis.com/WebUntis/api/rest/view/v1/messages` → JSON, works when authenticated
- `GET https://<server>.webuntis.com/api/rest/view/v1/messages` → SPA HTML shell, not the authenticated API used by this proof

Conclusion: the existing JS repo's message paths are aligned with the live tenant for inbox access, but the repo stops at preview-level inbox listing.

### 2. `/home/exedev/git/external/python-webuntis`

Python JSON-RPC client.

Relevant files:
- `README.rst`
- `docs/session.rst`
- `webuntis/session.py`

#### What it implements

The docs and session implementation expose JSON-RPC operations like:
- departments
- holidays
- klassen
- timetable
- rooms
- subjects
- teachers
- statusdata
- exams
- substitutions
- etc.

The session class stores `jsessionid` and uses JSON-RPC `_request()` calls.

#### What is missing

No message-center methods were found in code, docs, or repo search.

Search terms checked:
- `message`
- `inbox`
- `mail`
- `nachricht`
- `news`

None revealed a real inbox/message API implementation.

Conclusion: this repo is not suitable for WebUntis messages without new implementation work.

### 3. `/home/exedev/git/external/untis`

Elixir wrapper around the Untis Mobile / internal JSON-RPC API.

Relevant files:
- `README.md`
- `docs/json-rpc.md`
- `lib/untis/auth/json_auth.ex`
- `lib/untis/auth/totp.ex`
- `lib/untis.ex`
- `lib/untis/json_rpc.ex`

#### What it implements

This repo uses a different auth model than the JS and Python repos:
- fetch a shared app secret with `getAppSharedSecret`
- generate a TOTP from that shared secret
- call `jsonrpc_intern.do` methods with an `auth` map containing:
  - `user`
  - `otp`
  - `clientTime`

The repo exposes methods for:
- `getTimetable2017`
- `getHomeWork2017`
- `getMessagesOfDay2017`
- `getStudentAbsences2017`
- `getUserData2017`

#### Important observations

1. This repo is **not** targeting the same WebUntis web-client REST API used by the successful message proof.
2. It appears to target an older or more internal mobile-style JSON-RPC surface.
3. Its code hardcodes `https://mese.webuntis.com/...` in the HTTP calls, so it is not immediately usable for a different tenant without patching.
4. The message method is `getMessagesOfDay2017`, which suggests “messages of the day”, not inbox/message-center access.

#### What was verified

The shared-secret bootstrap endpoint worked on the tenant when called directly:
- `POST https://<server>.webuntis.com/WebUntis/jsonrpc_intern.do?school=<school-name>`
- method: `getAppSharedSecret`
- params: username + password

It returned a valid app shared secret string.

That means this auth model likely still works on the tenant, but this repo as checked out is not production-ready for our target because:
- base host is hardcoded incorrectly
- no inbox/message-center support is evident
- the proof requirement was full inbox message reading, which this repo does not appear to cover

Conclusion: valuable reference for alternate auth via shared-secret TOTP, but not the best implementation basis for guardian inbox reading.

### 4. `kaiser-jan/scriptable-untis`

Repo path used for review:
- `~/.cache/checkouts/github.com/kaiser-jan/scriptable-untis`

TypeScript project for iOS Scriptable widgets.

Relevant files:
- `README.md`
- `src/api/login.ts`
- `src/api/fetch.ts`

#### What it implements

This repo uses a modern browser-style auth and data-fetch flow:

1. POST credentials to:
   - `/WebUntis/j_spring_security_check`
2. collect cookies from the response
3. mint JWT via:
   - `/WebUntis/api/token/new`
4. fetch user data via:
   - `/WebUntis/api/rest/view/v1/app/data`
5. fetch timetable via:
   - `/WebUntis/api/public/timetable/weekly/pageconfig`
   - `/WebUntis/api/public/timetable/weekly/data`
6. fetch exams via:
   - `/WebUntis/api/exams?studentId=...`
7. fetch grades / absences via class register REST endpoints

#### What is useful here

This repo is a strong reference for modern WebUntis web-client calls, especially:
- browser-form login instead of JSON-RPC login
- timetable pageconfig discovery
- timetable weekly data fetch
- exam / grade / absence fetch patterns

It aligns well with the successful timetable proof work because it also uses `/WebUntis/api/...` routes.

#### What is missing for our use case

No inbox/message-center implementation was found in the reviewed files.
Searches found timetable, exams, grades, and absences, but not inbox/message detail flows.

No homework flow was found in the reviewed files either.

It also appears to assume the logged-in principal is the resource to query directly (`user.id`), so a guardian/dependent flow may need adaptation compared with the proof script that first resolves dependent students through `/WebUntis/api/rest/view/v1/timetable/menu`.

Conclusion: very useful reference repo for web-client auth and timetable/exam-related API usage, but not a direct answer for inbox messages and not obviously guardian-aware out of the box.

## Working API flow

The following flows worked against a live WebUntis tenant.

### Step 1: JSON-RPC login

Endpoint:
- `POST https://<server>.webuntis.com/WebUntis/jsonrpc.do?school=<school-name>`

Request body:

```json
{
  "id": "pi-test",
  "method": "authenticate",
  "params": {
    "user": "<username>",
    "password": "<password>",
    "client": "pi-test"
  },
  "jsonrpc": "2.0"
}
```

Useful response fields:
- `result.sessionId`
- `result.personType`
- `result.personId`
- `result.klasseId`

For the test account the login succeeded and returned a valid `sessionId`.

### Step 2: Build auth cookies

Two cookies mattered for the proof:

- `JSESSIONID=<sessionId>`
- `schoolname=_<base64-school-name>`

The proof used the same approach as the JS repo: it constructed the cookie header directly from the login result rather than relying on browser storage.

### Step 3: Mint JWT for message REST API

Endpoint:
- `GET https://<server>.webuntis.com/WebUntis/api/token/new`

Headers:

```http
Cookie: JSESSIONID=<sessionId>; schoolname=_<base64-school-name>
```

Response:
- plain JWT string

This JWT was then used as a bearer token for message-center REST endpoints.

### Message flow

### Step 4: Read inbox list

Endpoint:
- `GET https://<server>.webuntis.com/WebUntis/api/rest/view/v1/messages`

Headers:

```http
Authorization: Bearer <jwt>
Cookie: JSESSIONID=<sessionId>; schoolname=_<base64-school-name>
```

Observed response shape:

```json
{
  "incomingMessages": [
    {
      "id": 123456,
      "subject": "Example subject",
      "contentPreview": "Example preview text...",
      "sender": {
        "displayName": "Example Sender",
        "userId": 9999,
        "imageUrl": null,
        "className": null
      },
      "sentDateTime": "2026-04-02T10:24:00",
      "isMessageRead": true,
      "isReplyAllowed": false,
      "hasAttachments": false
    }
  ]
}
```

The original live proof returned real inbox data; the example above is redacted.

### Step 5: Read full message body

Endpoint:
- `GET https://<server>.webuntis.com/WebUntis/api/rest/view/v1/messages/{id}`

Also works with:
- `?contentAsHtml=false`
- `?contentAsHtml=true`

Observed detail response fields include more than the JS repo types currently model:
- `id`
- `subject`
- `content`
- `sender`
- `sentDateTime`
- `attachments`
- `blobAttachment`
- `storageAttachments`
- `isReply`
- `isReplyAllowed`
- `isReportMessage`
- `isReplyForbidden`
- `replyHistory`
- `requestConfirmation`

This is the endpoint that provides the full message body.

### Timetable flow

Guardian accounts do not map cleanly to the older JSON-RPC timetable element types. A direct JSON-RPC timetable query with a guardian-style `personType` failed with `invalid elementType`.

The newer web-client REST endpoints worked.

#### Step 1: Resolve dependent students

Endpoint:
- `GET https://<server>.webuntis.com/WebUntis/api/rest/view/v1/timetable/menu`

Headers:

```http
Authorization: Bearer <jwt>
Cookie: JSESSIONID=<sessionId>; schoolname=_<base64-school-name>
```

Observed response shape:

```json
{
  "myTimetable": null,
  "dependents": [
    {
      "type": "STUDENT",
      "resource": {
        "id": 1234,
        "shortName": "Example Student",
        "longName": "Example",
        "displayName": "Example Student"
      }
    }
  ],
  "availableTimetables": ["CLASS", "STUDENT"]
}
```

This endpoint exposes the guardian-visible dependent student ids.

#### Step 2: Read timetable entries

Endpoint:
- `GET https://<server>.webuntis.com/WebUntis/api/rest/view/v1/timetable/entries`

Important query params used in the proof:
- `start=2026-04-13`
- `end=2026-04-17`
- `resourceType=STUDENT`
- `resources=<student-id>`

Observed result:
- returned week timetable data under `days[]`
- each day contained `gridEntries[]`
- entries included start/end times, teacher, subject, room, and status

This proved that timetable access works for the dependent student through the guardian account.

## Auth and token behavior

### Password source used during research

The research used:
- `~/.env.webuntis`

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

The bundled proof scripts read this file directly by default.

### JWT lifetime

A decoded JWT showed:
- `iat` and `exp` differed by 900 seconds
- practical lifetime: about **15 minutes**

So the script should mint a fresh JWT per run instead of trying to reuse one.

### JSESSIONID lifetime

Observed login `Set-Cookie` behavior:
- `JSESSIONID` had **no `Expires` and no `Max-Age`** → session cookie
- `schoolname` and `Tenant-Id` had `Max-Age=1209600` (14 days), but those are not the actual authenticated server session

Practical conclusion:
- client-side cookie metadata does **not** define the real session lifetime
- the actual `JSESSIONID` lifetime is server-side and should not be assumed stable enough for unattended long-lived reuse
- for unattended jobs, the safe pattern is: **login fresh each run using stored username/password**

## Recommendation

For current needs, the most reliable path is a standalone script that:
1. reads `~/.env.webuntis`
2. performs JSON-RPC login
3. mints a fresh JWT
4. reads inbox
5. fetches full message content by id

That avoids depending on undocumented session persistence behavior.

Runnable proof files bundled in this skill:
- `references/proofs/2026-04-16_webuntis-message-access_README.md`
- `scripts/read-latest-message.py`
- `scripts/read-timetable.py`

The proof scripts use Python standard library only and read credentials from `~/.env.webuntis` by default.

## Next implementation options

1. Patch `/home/exedev/git/external/WebUntis` with full message-detail helpers.
2. Keep the standalone script as the operational tool for cron and diagnostics.
3. Add sent/drafts/reply/read-confirmation support if needed later.
