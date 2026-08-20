---
name: tasknotes
description: Manage TaskNotes tasks in Obsidian through maintained TaskNotes interfaces or a safe Markdown fallback. Use when the user wants to create, list, search, update, complete, archive, or delete tasks, or asks what they should work on.
---

# TaskNotes

Manage TaskNotes tasks through the safest available interface. Prefer maintained TaskNotes tools over hand-editing frontmatter because plugin operations preserve configured mappings, workflow behavior, recurrence, cache updates, and integrations.

## Default workflow

1. Find the Obsidian vault. Ask for its path if it is unknown.
2. Read `<vault>/.obsidian/plugins/tasknotes/data.json` when present. Do not print authentication tokens or unrelated settings.
3. Choose the first suitable interface below.
4. Inspect available statuses, priorities, and field mappings before writing values.
5. Perform the operation and verify the resulting task.

Do not install a CLI or enable the HTTP API without user approval.

## Choose an interface

### 1. Live TaskNotes: HTTP API or official CLI

Use a live interface when Obsidian is running and the operation can trigger TaskNotes behavior, including completion, recurrence, archive movement, dependencies, timers, notifications, or calendar synchronization.

TaskNotes offers:

- HTTP API at `http://localhost:8080/api` by default
- `tn` (`tasknotes-cli`), which uses the HTTP API
- built-in `obsidian tasknotes:*` commands for capture, timers, and Pomodoro

Probe existing tools before using them:

```bash
command -v tn
command -v obsidian
curl -fsS http://localhost:8080/api/health
```

The HTTP API is desktop-only, disabled by default, and bound to loopback. If TaskNotes has an API token, send it as `Authorization: Bearer <token>` without logging it.

Useful endpoints:

| Method | Endpoint | Purpose |
|---|---|---|
| `GET` | `/api/tasks?limit=50&offset=0` | List tasks with pagination |
| `POST` | `/api/tasks/query` | Filter or sort tasks |
| `POST` | `/api/tasks` | Create a task |
| `GET` | `/api/tasks/{id}` | Read one task |
| `PUT` | `/api/tasks/{id}` | Update one task |
| `DELETE` | `/api/tasks/{id}` | Delete one task |
| `GET` | `/api/filter-options` | Read valid statuses, priorities, and projects |
| `GET` | `/api/stats` | Read task statistics |

Do not send filters such as `status`, `priority`, `project`, or `overdue` to `GET /api/tasks`; current TaskNotes rejects them. Use `POST /api/tasks/query`.

Example query for open tasks, sorted by due date:

```json
{
  "type": "group",
  "id": "root",
  "conjunction": "and",
  "children": [
    {
      "type": "condition",
      "id": "status",
      "property": "status",
      "operator": "is",
      "value": "open"
    }
  ],
  "sortKey": "due",
  "sortDirection": "asc"
}
```

Use `tn --help`, `obsidian help`, or the live API documentation at `/api/docs` for commands and fields supported by the installed version.

### 2. Headless or direct-file work: `mtn`

Prefer `mtn` (`mdbase-tasknotes`) when Obsidian is closed, on a remote machine, or when a script must operate directly on Markdown files. It reads the generated mdbase schema, including custom statuses and priorities.

Probe it first:

```bash
command -v mtn
mtn config --get collectionPath
```

Common commands:

```bash
mtn list --json
mtn list --status in-progress
mtn list --overdue
mtn create "Review pull request tomorrow #work +backend"
mtn update "Review pull request" --status in-progress
mtn complete "Review pull request"
mtn archive "Review pull request"
mtn delete "Review pull request"
```

If `mtn` is installed but not configured, ask before changing its configuration.

### 3. Manual Markdown fallback

Use direct file reads for inspection when no maintained interface is available. Use direct writes only for basic task creation or simple frontmatter updates. Do not manually implement recurrence advancement, archive movement, dependency changes, timers, notifications, or calendar behavior.

## Manual fallback details

### Read configuration

Read `<vault>/.obsidian/plugins/tasknotes/data.json` and account for:

- `tasksFolder`
- `taskIdentificationMethod`
- `taskTag`
- `taskPropertyName` and `taskPropertyValue`
- `fieldMapping`
- `defaultTaskStatus` and `defaultTaskPriority`
- `customStatuses` and `customPriorities`
- `storeTitleInFilename`, `taskFilenameFormat`, and `customFilenameTemplate`

If the task folder or filename template contains unresolved variables, ask for the missing context instead of guessing.

### Identify a task

For tag-based identification, include the configured task tag:

```yaml
tags:
  - task
```

For property-based identification, write the configured property name and value instead. Do not add the task tag unless the configuration requires it.

### Respect field mappings

`fieldMapping` maps TaskNotes semantic fields to the vault's YAML property names. For example, if `due` maps to `deadline`, write `deadline:` rather than `due:`. Preserve unknown frontmatter and the note body when updating a task.

### Create a basic task

With default tag identification and default field mappings:

```markdown
---
tags:
  - task
title: "Review pull request"
status: open
priority: normal
due: "2026-08-21"
dateCreated: "2026-08-20T10:00:00.000Z"
dateModified: "2026-08-20T10:00:00.000Z"
---

Review API behavior and test coverage.
```

Use current timestamps, not the example values.

When title-based filenames are active:

- collapse whitespace
- remove `<>:"/\\|?*#[]` and control characters
- trim leading and trailing dots
- avoid Windows reserved names
- append `-2`, `-3`, and so on when a file exists

When another filename mode is configured, use the maintained API or CLI unless its behavior can be reproduced safely.

### Update or complete a task

Update the mapped `dateModified` field whenever changing frontmatter. Determine completion from the configured status metadata instead of assuming every vault uses `done`.

For a basic default completion:

```yaml
status: done
completedDate: "2026-08-20"
dateModified: "2026-08-20T15:00:00.000Z"
```

After a manual write, reread the file and confirm that the identification marker, mapped fields, and body are intact.

## Listing and prioritization

When no CLI or API is available:

1. Search the configured task folder recursively for Markdown files.
2. Parse YAML frontmatter; do not rely on `grep` alone for lists or remapped fields.
3. Select tasks using the configured identification method.
4. Exclude statuses marked completed when listing active work.
5. Sort urgent or high-priority tasks first, then overdue and due dates, then scheduled dates.
6. Show task title, status, priority, due or scheduled date, and project when available.
