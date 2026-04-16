#!/usr/bin/env python3
import base64
import json
import os
from pathlib import Path
from urllib import error, parse, request


def parse_env_file(file_path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    for raw_line in file_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue

        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()

        if (value.startswith("'") and value.endswith("'")) or (
            value.startswith('"') and value.endswith('"')
        ):
            value = value[1:-1]

        data[key] = value

    return data


def require_value(name: str, value: str | None) -> str:
    if not value:
        raise RuntimeError(f"Missing required config: {name}")
    return value


def http_json(url: str, *, method: str = "GET", headers: dict[str, str] | None = None, body: dict | None = None):
    payload = None
    request_headers = headers.copy() if headers else {}
    if body is not None:
        payload = json.dumps(body).encode("utf-8")
        request_headers.setdefault("Content-Type", "application/json")

    req = request.Request(url, data=payload, headers=request_headers, method=method)
    try:
        with request.urlopen(req) as response:
            text = response.read().decode("utf-8")
    except error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code} from {url}: {detail[:300]}") from exc

    try:
        return json.loads(text)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"Expected JSON from {url}, got: {text[:300]}") from exc



def http_text(url: str, *, method: str = "GET", headers: dict[str, str] | None = None):
    req = request.Request(url, headers=headers or {}, method=method)
    try:
        with request.urlopen(req) as response:
            return response.read().decode("utf-8")
    except error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code} from {url}: {detail[:300]}") from exc



def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Read the latest full WebUntis inbox message")
    parser.add_argument("--host", default=None, help="WebUntis host, e.g. school.webuntis.com")
    parser.add_argument("--school", default=None, help="WebUntis school name")
    args = parser.parse_args()

    env_file = Path(os.environ.get("WEBUNTIS_ENV_FILE", str(Path.home() / ".env.webuntis")))
    file_env = parse_env_file(env_file) if env_file.exists() else {}

    host = require_value("WEBUNTIS_HOST", args.host or os.environ.get("WEBUNTIS_HOST") or file_env.get("WEBUNTIS_HOST"))
    school = require_value("WEBUNTIS_SCHOOL", args.school or os.environ.get("WEBUNTIS_SCHOOL") or file_env.get("WEBUNTIS_SCHOOL"))
    client_id = os.environ.get("WEBUNTIS_CLIENT_ID") or file_env.get("WEBUNTIS_CLIENT_ID") or "webuntis-proof"
    username = require_value("WEBUNTIS_USERNAME", os.environ.get("WEBUNTIS_USERNAME") or file_env.get("WEBUNTIS_USERNAME"))
    password = require_value("WEBUNTIS_PASSWORD", os.environ.get("WEBUNTIS_PASSWORD") or file_env.get("WEBUNTIS_PASSWORD"))

    jsonrpc_url = f"https://{host}/WebUntis/jsonrpc.do?school={parse.quote(school)}"
    school_cookie = "_" + base64.b64encode(school.encode("utf-8")).decode("ascii")

    print(f"Using env file: {env_file}")
    print(f"Host: {host}")
    print(f"School: {school}")
    print(f"User: {username}")
    print()
    print("Step 1: POST /WebUntis/jsonrpc.do?school=... authenticate")

    auth = http_json(
        jsonrpc_url,
        method="POST",
        headers={"Accept": "application/json"},
        body={
            "id": client_id,
            "method": "authenticate",
            "params": {
                "user": username,
                "password": password,
                "client": client_id,
            },
            "jsonrpc": "2.0",
        },
    )

    session_id = auth.get("result", {}).get("sessionId")
    if not session_id:
        raise RuntimeError(f"Authentication failed: {json.dumps(auth)}")

    cookie_header = f"JSESSIONID={session_id}; schoolname={school_cookie}"
    print(
        "Authenticated. "
        f"personType={auth['result'].get('personType')} "
        f"personId={auth['result'].get('personId')}"
    )
    print()
    print("Step 2: GET /WebUntis/api/token/new")

    jwt = http_text(
        f"https://{host}/WebUntis/api/token/new",
        headers={"Cookie": cookie_header},
    )
    print(f"Minted JWT ({len(jwt)} chars)")
    print()
    print("Step 3: GET /WebUntis/api/rest/view/v1/messages")

    auth_headers = {
        "Authorization": f"Bearer {jwt}",
        "Cookie": cookie_header,
        "Accept": "application/json, text/plain, */*",
        "X-Requested-With": "XMLHttpRequest",
    }
    inbox = http_json(f"https://{host}/WebUntis/api/rest/view/v1/messages", headers=auth_headers)

    messages = list(inbox.get("incomingMessages") or [])
    if not messages:
        print("Inbox is empty.")
        return

    messages.sort(key=lambda msg: str(msg.get("sentDateTime", "")), reverse=True)
    latest = messages[0]

    print(f"Inbox messages: {len(messages)}")
    print(
        "Latest preview: "
        f"{latest.get('sentDateTime')} | "
        f"{(latest.get('sender') or {}).get('displayName', 'unknown')} | "
        f"{latest.get('subject')}"
    )
    print()
    print(f"Step 4: GET /WebUntis/api/rest/view/v1/messages/{latest['id']}")

    detail = http_json(
        f"https://{host}/WebUntis/api/rest/view/v1/messages/{latest['id']}?contentAsHtml=false",
        headers=auth_headers,
    )

    print("--- Latest message ---")
    print(f"ID: {detail.get('id')}")
    print(f"Date: {detail.get('sentDateTime')}")
    print(f"Sender: {(detail.get('sender') or {}).get('displayName', 'unknown')}")
    print(f"Subject: {detail.get('subject')}")
    print()
    print(detail.get("content") or "[no content]")


if __name__ == "__main__":
    main()
