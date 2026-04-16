#!/usr/bin/env python3
import argparse
import base64
import json
import os
from datetime import date, timedelta
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
        raise RuntimeError(f"HTTP {exc.code} from {url}: {detail[:500]}") from exc

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



def monday_and_friday(day: date) -> tuple[date, date]:
    monday = day - timedelta(days=day.weekday())
    friday = monday + timedelta(days=4)
    return monday, friday



def load_config(cli_host: str | None, cli_school: str | None) -> dict[str, str]:
    env_file = Path(os.environ.get("WEBUNTIS_ENV_FILE", str(Path.home() / ".env.webuntis")))
    file_env = parse_env_file(env_file) if env_file.exists() else {}

    return {
        "env_file": str(env_file),
        "host": require_value("WEBUNTIS_HOST", cli_host or os.environ.get("WEBUNTIS_HOST") or file_env.get("WEBUNTIS_HOST")),
        "school": require_value("WEBUNTIS_SCHOOL", cli_school or os.environ.get("WEBUNTIS_SCHOOL") or file_env.get("WEBUNTIS_SCHOOL")),
        "client_id": os.environ.get("WEBUNTIS_CLIENT_ID") or file_env.get("WEBUNTIS_CLIENT_ID") or "webuntis-proof",
        "username": require_value("WEBUNTIS_USERNAME", os.environ.get("WEBUNTIS_USERNAME") or file_env.get("WEBUNTIS_USERNAME")),
        "password": require_value("WEBUNTIS_PASSWORD", os.environ.get("WEBUNTIS_PASSWORD") or file_env.get("WEBUNTIS_PASSWORD")),
        "student_id": os.environ.get("WEBUNTIS_STUDENT_ID") or file_env.get("WEBUNTIS_STUDENT_ID") or "",
    }



def login_and_headers(config: dict[str, str]) -> tuple[dict, dict[str, str]]:
    host = config["host"]
    school = config["school"]
    client_id = config["client_id"]

    auth = http_json(
        f"https://{host}/WebUntis/jsonrpc.do?school={parse.quote(school)}",
        method="POST",
        headers={"Accept": "application/json"},
        body={
            "id": client_id,
            "method": "authenticate",
            "params": {
                "user": config["username"],
                "password": config["password"],
                "client": client_id,
            },
            "jsonrpc": "2.0",
        },
    )

    session_id = auth.get("result", {}).get("sessionId")
    if not session_id:
        raise RuntimeError(f"Authentication failed: {json.dumps(auth)}")

    school_cookie = "_" + base64.b64encode(school.encode("utf-8")).decode("ascii")
    cookie_header = f"JSESSIONID={session_id}; schoolname={school_cookie}"
    jwt = http_text(
        f"https://{host}/WebUntis/api/token/new",
        headers={"Cookie": cookie_header},
    )

    headers = {
        "Authorization": f"Bearer {jwt}",
        "Cookie": cookie_header,
        "Accept": "application/json, text/plain, */*",
        "X-Requested-With": "XMLHttpRequest",
    }
    return auth["result"], headers



def choose_student(host: str, headers: dict[str, str], configured_student_id: str | None):
    menu = http_json(f"https://{host}/WebUntis/api/rest/view/v1/timetable/menu", headers=headers)
    dependents = menu.get("dependents") or []
    if not dependents:
        raise RuntimeError("No dependent students found in timetable menu")

    if configured_student_id:
        for item in dependents:
            resource = item.get("resource") or {}
            if str(resource.get("id")) == str(configured_student_id):
                return item, dependents
        raise RuntimeError(f"Configured student id {configured_student_id} not found in dependents")

    return dependents[0], dependents



def format_entry(entry: dict) -> str:
    start = ((entry.get("duration") or {}).get("start") or "")[11:16]
    end = ((entry.get("duration") or {}).get("end") or "")[11:16]

    def names(position_key: str) -> str:
        values = []
        for item in entry.get(position_key) or []:
            current = item.get("current") or {}
            values.append(current.get("displayName") or current.get("longName") or current.get("shortName") or "")
        values = [v for v in values if v]
        return ", ".join(values)

    subject = names("position2") or "?"
    teacher = names("position1") or "?"
    room = names("position3") or "?"
    status = entry.get("status") or "UNKNOWN"
    return f"{start}-{end} | {subject} | {teacher} | {room} | {status}"



def collect_teachers(timetable: dict) -> dict[str, str]:
    teachers: dict[str, str] = {}

    for day in timetable.get("days") or []:
        for entry in day.get("gridEntries") or []:
            for item in entry.get("position1") or []:
                current = item.get("current") or {}
                short_name = current.get("shortName")
                long_name = current.get("longName") or current.get("displayName") or short_name
                if short_name:
                    teachers[str(short_name)] = str(long_name)

    return dict(sorted(teachers.items()))



def main() -> None:
    parser = argparse.ArgumentParser(description="Read WebUntis timetable proof")
    parser.add_argument("--host", default=None, help="WebUntis host, e.g. school.webuntis.com")
    parser.add_argument("--school", default=None, help="WebUntis school name")
    parser.add_argument("--date", default=str(date.today()), help="Reference date in YYYY-MM-DD. Default: today")
    parser.add_argument("--student-id", default=None, help="Dependent student id override")
    parser.add_argument("--teachers", action="store_true", help="Print only the teacher code-to-name mapping for the selected week")
    args = parser.parse_args()

    target_date = date.fromisoformat(args.date)
    week_start, week_end = monday_and_friday(target_date)

    config = load_config(args.host, args.school)
    configured_student_id = args.student_id or config.get("student_id") or ""
    auth_result, headers = login_and_headers(config)
    host = config["host"]

    selected, dependents = choose_student(host, headers, configured_student_id)
    resource = selected.get("resource") or {}
    student_id = resource.get("id")
    student_name = resource.get("displayName") or resource.get("shortName") or resource.get("longName") or str(student_id)

    timetable = http_json(
        f"https://{host}/WebUntis/api/rest/view/v1/timetable/entries"
        f"?start={week_start.isoformat()}&end={week_end.isoformat()}"
        f"&resourceType=STUDENT&resources={student_id}",
        headers=headers,
    )

    print(f"Using env file: {config['env_file']}")
    print(f"Host: {host}")
    print(f"School: {config['school']}")
    print(f"Guardian user: {config['username']}")
    print(f"Authenticated guardian personType={auth_result.get('personType')} personId={auth_result.get('personId')}")
    print()
    print("Dependents:")
    for item in dependents:
        dependent = item.get("resource") or {}
        print(f"- {dependent.get('id')}: {dependent.get('displayName') or dependent.get('shortName') or dependent.get('longName')}")
    print()
    print(f"Selected student: {student_name} ({student_id})")
    print(f"Week: {week_start.isoformat()} .. {week_end.isoformat()}")
    print()

    if args.teachers:
        print("Teachers:")
        for short_name, long_name in collect_teachers(timetable).items():
            print(f"- {short_name}: {long_name}")
        return

    for day in timetable.get("days") or []:
        print(f"=== {day.get('date')} ===")
        grid_entries = day.get("gridEntries") or []
        if not grid_entries:
            print("[no entries]")
            print()
            continue

        for entry in grid_entries:
            print(format_entry(entry))
        print()


if __name__ == "__main__":
    main()
