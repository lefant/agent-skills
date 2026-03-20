# devenv Migration Skill

A comprehensive skill for migrating from nix-shell to devenv or creating new devenv projects.

## Structure

```
devenv-migration/
├── SKILL.md                          # Main skill file (460 lines)
├── references/                       # Detailed guides (3,918 lines total)
│   ├── migration-guide.md           # nix-shell → devenv conversion (633 lines)
│   ├── language-configs.md          # Python, JS, Elm, Go, Rust (751 lines)
│   ├── services-guide.md            # PostgreSQL, Redis, MySQL (854 lines)
│   ├── processes-tasks.md           # Process orchestration (917 lines)
│   └── troubleshooting.md           # Common issues and solutions (763 lines)
└── assets/
    └── templates/                   # Ready-to-use configs (769 lines total)
        ├── basic-devenv.nix         # Minimal starter (59 lines)
        ├── python-backend.nix       # Python + PostgreSQL + Redis (172 lines)
        ├── fullstack.nix            # Backend + Frontend pattern (249 lines)
        ├── multi-language.nix       # Python + JS + Go example (249 lines)
        └── devenv.yaml              # Nixpkgs inputs config (40 lines)
```

## Statistics

- **Total lines:** 5,147
- **Reference files:** 5 files, 3,918 lines
- **Templates:** 5 files, 769 lines
- **Main file:** 460 lines (within recommended 200-500 range)

## Coverage

### Languages
- Python (with venv, uv, poetry)
- JavaScript/Node (npm, yarn, pnpm)
- Elm (with elm-land)
- Go
- Rust
- Multi-language projects

### Services
- PostgreSQL (versions, initialization, extensions)
- Redis (persistence, configuration)
- MySQL, MongoDB, Elasticsearch, RabbitMQ, Nginx, Caddy

### Features
- Process orchestration with dependencies
- Health checks and restart policies
- Scripts and task system
- Pre-commit hooks integration
- Platform-specific handling (Linux patchelf, macOS frameworks, WSL)

### Real-World Example
Based on Hakuto project migration:
- 150+ line default.nix → 80-100 line devenv.nix
- Python + uv + PostgreSQL 17 + Redis
- Elm + elm-land + Tailwind CSS
- OpenAPI client generation
- Process orchestration
- Platform-specific patchelf logic

## Usage

This skill is triggered when users:
- Mention migrating from nix-shell to devenv
- Ask about devenv configuration
- Need help with language/service/process setup
- Have devenv-related issues

## Validation

✅ Correct directory structure
✅ YAML frontmatter in SKILL.md
✅ All reference files created
✅ All template files created
✅ Progressive disclosure (main file < 500 lines)
✅ Comprehensive coverage of devenv features
✅ Real-world examples from Hakuto
✅ Platform-specific solutions included

## Testing Recommendations

1. **Structure validation:** Check that all files exist and are readable
2. **Content verification:** Verify references and templates have correct syntax
3. **Real usage:** Test migration of Hakuto's default.nix
4. **Integration:** Test skill triggers correctly in Claude Code sessions

## Lessons Learned (from Hakuto Migration)

### Critical Gotchas

1. **PostgreSQL initialScript Quoting**
   - SQL empty string `''` conflicts with Nix string syntax
   - Solution: Use `''''` for escaped quotes

2. **Python uv in Monorepos**
   - `uv.sync.enable` runs from root, fails if `pyproject.toml` is in subdirectory
   - Solution: Disable auto-sync, run manually from correct directory

3. **nixpkgs-python Required**
   - `languages.python.version` requires `nixpkgs-python` input
   - Add to `devenv.yaml` with `follows: nixpkgs`

4. **Code Generation Order**
   - Generated code must exist before builds that depend on it
   - Use `enterTest` for generation, `enterShell` for builds

5. **process-compose Environment Format**
   - Must be list of strings: `["KEY=VALUE"]`
   - Not Nix attribute set: `{ KEY = "VALUE"; }`

6. **Process Dependencies**
   - Use one-time processes with `exit 0` and `restart = "no"`
   - Depend on `process_completed_successfully` condition

### Best Practices

- **enterTest:** Code generation, asset compilation
- **enterShell:** Environment setup, conditional builds
- **processes:** Long-running services with health checks
- **scripts:** On-demand tasks

## Author Notes

Created based on:
- Hakuto project's nix-shell setup (complex real-world example)
- devenv official documentation
- skill-creator best practices
- Progressive disclosure principles

Key design decisions:
- Split references by topic for better discoverability
- Templates range from basic to fullstack
- Bundled common patterns, Context7 for latest API
- Platform-aware solutions for Linux/macOS/WSL
- Updated with real migration learnings from Hakuto
