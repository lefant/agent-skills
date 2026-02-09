---
name: tasknotes
description: Create and manage tasks in Obsidian via the TaskNotes plugin by writing markdown files directly. Use when user wants to create tasks, list tasks, update task status, or check what they need to do.
---

# TaskNotes Skill

Create and manage Obsidian tasks by writing markdown files with YAML frontmatter directly to the vault. No HTTP API or CLI required -- TaskNotes picks up files automatically.

## How TaskNotes Works

Each task is a separate markdown file with YAML frontmatter stored in a configured folder inside an Obsidian vault. TaskNotes identifies tasks by the presence of `tags: [task]` in frontmatter (default method). All views (kanban, calendar, task list) are powered by Obsidian Bases querying these files.

## Vault Location

The Obsidian vault path must be known. Common locations:

- Linux: `~/Documents/Obsidian/VaultName/` or `~/Obsidian/VaultName/`
- macOS: `~/Documents/VaultName/` or `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultName/`

If unknown, ask the user for their vault path.

## Tasks Folder

Default: `TaskNotes/Tasks/` inside the vault root.

The user may have configured a different folder in their TaskNotes plugin settings. The settings are stored at:
```
<vault>/.obsidian/plugins/tasknotes/data.json
```
Read `tasksFolder` from that file if you need to confirm the path. You can also check the `taskTag`, `taskIdentificationMethod`, `fieldMapping`, `customStatuses`, and `customPriorities` settings to match the user's configuration.

## Creating a Task

Write a `.md` file to the tasks folder with this structure:

```markdown
---
tags:
  - task
title: "Task title here"
status: open
priority: normal
dateCreated: "2026-02-09T10:30:00.000Z"
dateModified: "2026-02-09T10:30:00.000Z"
---

Optional body content, notes, context, or details.
```

### Filename

Use the sanitized title as the filename (default TaskNotes behavior):
- Replace `<>:"/\|?*#[]` with nothing
- Replace multiple spaces with single space
- Trim leading/trailing dots
- Append `.md`

Example: `"Buy groceries tomorrow"` -> `Buy groceries tomorrow.md`

If a file with that name already exists, append `-2`, `-3`, etc.

### Required Fields

| Field | Description |
|-------|-------------|
| `tags` | Must include `task` for TaskNotes to recognize the file |
| `title` | The task title |
| `status` | Task status (see defaults below) |
| `dateCreated` | ISO 8601 timestamp of creation |
| `dateModified` | ISO 8601 timestamp (same as dateCreated initially) |

### Common Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `priority` | string | `none`, `low`, `normal`, `high` |
| `due` | date | Due date as `YYYY-MM-DD` |
| `scheduled` | date | Date to work on it as `YYYY-MM-DD` |
| `contexts` | string[] | Context tags, e.g. `["@work", "@home"]` |
| `projects` | string[] | Project links as wikilinks, e.g. `["[[Project Name]]"]` |
| `timeEstimate` | number | Estimated minutes |
| `completedDate` | date | Date completed as `YYYY-MM-DD` |
| `recurrence` | string | RFC 5545 RRULE, e.g. `FREQ=WEEKLY;BYDAY=MO` |

### Default Status Values

| Value | Meaning | Completed? |
|-------|---------|------------|
| `open` | New task | No |
| `in-progress` | Being worked on | No |
| `done` | Finished | Yes |
| `none` | Unset | No |

### Default Priority Values

| Value | Weight |
|-------|--------|
| `none` | 0 |
| `low` | 1 |
| `normal` | 2 |
| `high` | 3 |

## Updating a Task

Read the existing `.md` file, modify its YAML frontmatter, update `dateModified` to the current timestamp, and write it back.

To mark a task done:
```yaml
status: done
completedDate: "2026-02-09"
dateModified: "2026-02-09T15:00:00.000Z"
```

## Listing Tasks

Use Glob and Grep to find and read task files:

```
Glob: <vault>/TaskNotes/Tasks/*.md
Grep: pattern="^status:" in those files
```

Parse the YAML frontmatter to extract task properties for display.

## Reading User Configuration

To respect user customizations, read `<vault>/.obsidian/plugins/tasknotes/data.json`:

```json
{
  "tasksFolder": "TaskNotes/Tasks",
  "taskTag": "task",
  "taskIdentificationMethod": "tag",
  "defaultTaskStatus": "open",
  "defaultTaskPriority": "normal",
  "fieldMapping": {
    "title": "title",
    "status": "status",
    "priority": "priority",
    "due": "due",
    "scheduled": "scheduled",
    "contexts": "contexts",
    "projects": "projects",
    "timeEstimate": "timeEstimate",
    "completedDate": "completedDate",
    "dateCreated": "dateCreated",
    "dateModified": "dateModified"
  },
  "customStatuses": [...],
  "customPriorities": [...]
}
```

Use the `fieldMapping` values as the actual YAML property names. Use `customStatuses` and `customPriorities` for valid values.

## Field Mapping

All property names are configurable by the user. The `fieldMapping` in `data.json` maps internal names to what the user chose. For example, if a user remapped `due` to `deadline`, write `deadline:` instead of `due:` in frontmatter. Always check the mapping before creating tasks.

## When to Use

- "create a task for X" -> create task file
- "show my tasks" -> glob + grep task files
- "what should I work on" -> list non-done tasks sorted by priority/due
- "mark X as done" -> update task frontmatter
- "schedule X for tomorrow" -> set scheduled date

## Example

Creating a high-priority task with a due date:

File: `<vault>/TaskNotes/Tasks/Review pull request.md`
```markdown
---
tags:
  - task
title: "Review pull request"
status: open
priority: high
due: "2026-02-10"
scheduled: "2026-02-09"
dateCreated: "2026-02-09T10:00:00.000Z"
dateModified: "2026-02-09T10:00:00.000Z"
contexts:
  - "@work"
projects:
  - "[[Backend Refactor]]"
---

PR #456 - needs security review before merge.
```
