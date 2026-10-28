---
name: caveman-help
description: >-
  Quick reference for Caveman modes and commands; does not activate them.
  Use only when explicitly requested by name or enabled in repository instructions.
disable-model-invocation: true
---

> **Local opt-in policy:** Use this skill only when the user explicitly requests it or repository instructions explicitly enable it. Installation alone does not enable it. This scope applies to all guidance below, including sibling-skill references. Enabling one skill does not enable its siblings or authorize external changes.

# Caveman Help

Display this reference card when invoked. One-shot — do NOT change mode, write flag files, or persist anything. Output in caveman style.

## Modes

| Mode | Trigger | What change |
|------|---------|-------------|
| **Lite** | `/caveman` or `/caveman lite` | Drop filler. Keep sentence structure. Default in lefant bundle. |
| **Full** | `/caveman full` | Drop articles, filler, pleasantries, hedging. Fragments OK. Classic caveman. |
| **Ultra** | `/caveman ultra` | Extreme compression. Bare fragments. Tables over prose. |
| **Wenyan-Lite** | `/caveman wenyan-lite` | Classical Chinese style, light compression. |
| **Wenyan-Full** | `/caveman wenyan` | Full 文言文. Maximum classical terseness. |
| **Wenyan-Ultra** | `/caveman wenyan-ultra` | Extreme. Ancient scholar on a budget. |

Mode stick until changed or session end.

## Skills

| Skill | Trigger | What it do |
|-------|---------|-----------|
| **caveman-commit** | `/caveman-commit` | Terse commit messages. Conventional Commits. ≤50 char subject. |
| **caveman-review** | `/caveman-review` | One-line PR comments: `L42: bug: user null. Add guard.` |
| **caveman-compress** | `/caveman-compress <file>` | Compress .md files to caveman prose. Saves ~46% input tokens. |
| **caveman-help** | `/caveman-help` | This card. |

## Deactivate

Say "stop caveman" or "normal mode". Resume anytime with `/caveman`.

## Language

Keep user's language by default. User write Portuguese → reply Portuguese caveman. Compress the style, not the language. Technical terms, code, commands, commit types, and exact error strings stay verbatim unless user ask for translation.

## Configure Default Mode

Default mode = `lite`. Change it:

**Environment variable** (highest priority):
```bash
export CAVEMAN_DEFAULT_MODE=ultra
```

**Config file** (`~/.config/caveman/config.json`):
```json
{ "defaultMode": "lite" }
```

These settings belong to the upstream plugin; this vendored bundle includes no session-start hooks or config loader. Here, choose a mode explicitly with `/caveman <mode>`; installing the skills does not activate them.

Resolution: env var > config file > `lite`.

## More

Full docs: https://github.com/JuliusBrussee/caveman
