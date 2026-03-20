# Git Hooks (Pre-commit) Guide

Devenv integrates git-hooks.nix (formerly pre-commit-hooks.nix) for declarative pre-commit hook management.

## What is prek?

**prek** is a Nix-native replacement for pre-commit that's built into devenv via git-hooks.nix. When you configure `git-hooks.hooks.*` in devenv.nix, devenv automatically:

1. Installs prek and all required hook packages
2. Configures hooks based on your settings
3. Installs Git hooks when you enter `devenv shell`
4. Manages hook execution and caching

**Key benefit:** No manual pre-commit installation or `.pre-commit-config.yaml` needed - everything is declarative in devenv.nix.

### prek vs Traditional pre-commit

| Traditional pre-commit | prek (via devenv) |
|------------------------|-------------------|
| Install: `pip install pre-commit` | Automatic via devenv |
| Config: `.pre-commit-config.yaml` | Config: `devenv.nix` |
| Install hooks: `pre-commit install` | Automatic on `devenv shell` |
| Update deps: `pre-commit autoupdate` | Managed by Nix |
| Package isolation: Python venv | Nix store isolation |
| Cross-platform issues | Nix handles platform differences |

**Bottom line:** prek is fully integrated into devenv, so you configure hooks once in devenv.nix and everything else is automatic.

## Quick Start

```nix
{ pkgs, ... }:

{
  # Configure prek as the git-hooks package (REQUIRED)
  git-hooks.package = pkgs.prek;

  # Enable git hooks
  git-hooks.hooks = {
    # Simple hooks - just enable them
    nixfmt-rfc-style.enable = true;
    shellcheck.enable = true;

    # Hooks with configuration
    prettier = {
      enable = true;
      excludes = [ ".*\\.lock" ];
    };
  };
}
```

**That's it!** When you run `devenv shell`, prek automatically:
- Installs all configured hooks
- Sets up `.git/hooks/pre-commit` (and other stages)
- Manages hook execution and caching

**IMPORTANT:** The `git-hooks.package = pkgs.prek;` line is required to use prek instead of the default pre-commit implementation.

## Key Concepts

### Built-in Hooks vs Custom Hooks

**Built-in hooks** (preferred):
- Native git-hooks.nix implementations
- Just enable with `.enable = true`
- No need to specify package or entry point
- Examples: `check-merge-conflicts`, `end-of-file-fixer`, `trim-trailing-whitespace`

**Custom hooks**:
- When no built-in hook exists
- Must specify `entry`, `language`, `files`, etc.
- Example: Alembic-specific validation hooks

### Hook Configuration

Every hook supports these common options:

```nix
hooks.myHook = {
  enable = true;

  # Optional: file patterns to match
  files = "\\.py$";

  # Optional: exclude patterns
  excludes = [ "generated/" ".*\\.lock" ];

  # Optional: override file type detection
  types = [ "python" ];
  types_or = [ "javascript" "jsx" "ts" "tsx" ];

  # Optional: when to run (default: pre-commit)
  stages = [ "pre-commit" "pre-push" "manual" ];

  # Optional: pass filenames to hook
  pass_filenames = false;
};
```

## Migration from Python Packages

**BEFORE (using Nix Python packages):**
```nix
packages = [
  python313Packages.pre-commit-hooks
];

git-hooks.hooks = {
  check-added-large-files = {
    enable = true;
    name = "Check for added large files";
    entry = "${pkgs.python313Packages.pre-commit-hooks}/bin/check-added-large-files";
    language = "system";
    stages = [ "pre-push" ];
  };
};
```

**AFTER (using built-in hooks):**
```nix
git-hooks.hooks = {
  check-added-large-files = {
    enable = true;
    stages = [ "pre-push" ];
  };
};
```

**Benefits:**
- No manual package references
- Cleaner configuration
- Automatic package management
- Better integration with devenv

## Available Hooks (171 total)

### General File Checks
- `check-added-large-files` - Prevent large files from being committed
- `check-case-conflicts` - Check for case-insensitive filename conflicts
- `check-merge-conflicts` - Detect merge conflict markers
- `check-symlinks` - Find broken symlinks
- `check-executables-have-shebangs` - Ensure executables have shebangs
- `check-shebang-scripts-are-executable` - Ensure scripts with shebangs are executable
- `detect-private-keys` - Find accidentally committed private keys
- `detect-aws-credentials` - Find AWS credentials
- `end-of-file-fixer` - Ensure files end with newline
- `fix-byte-order-marker` - Remove UTF-8 BOM
- `mixed-line-endings` - Detect mixed line endings
- `trim-trailing-whitespace` - Remove trailing whitespace
- `forbid-new-submodules` - Prevent new git submodules

### Language-Specific: Nix
- `alejandra` - Nix formatter
- `deadnix` - Find unused Nix code
- `nixfmt` - Official Nix formatter (latest)
- `nixfmt-classic` - Nix formatter (pre-1.0)
- `nixfmt-rfc-style` - Nix formatter (RFC 166 style)
- `nixpkgs-fmt` - Nixpkgs formatter
- `nil` - Nix language server diagnostics
- `nixf-diagnose` - Nix semantic analysis
- `statix` - Nix linter with suggestions

### Language-Specific: Python
- `autoflake` - Remove unused imports/variables
- `black` - Code formatter
- `flake8` - Linter
- `flynt` - Convert to f-strings
- `isort` - Sort imports
- `mypy` - Type checker
- `pylint` - Linter
- `pyright` - Type checker
- `python-debug-statements` - Check for debugger imports
- `pyupgrade` - Upgrade syntax for newer Python
- `ruff` - Fast linter
- `ruff-format` - Fast formatter

### Language-Specific: JavaScript/TypeScript
- `biome` - Fast formatter/linter (replaces rome)
- `denofmt` - Deno formatter
- `denolint` - Deno linter
- `eslint` - JavaScript linter
- `prettier` - Multi-language formatter

### Language-Specific: Go
- `gofmt` - Go formatter
- `golangci-lint` - Go linter suite
- `golines` - Go line length formatter
- `gotest` - Run Go tests
- `govet` - Go static analysis
- `revive` - Go linter
- `staticcheck` - Go static analyzer

### Language-Specific: Rust
- `cargo-check` - Check Rust code
- `clippy` - Rust linter
- `rustfmt` - Rust formatter

### Language-Specific: Haskell
- `fourmolu` - Haskell formatter
- `hindent` - Haskell formatter
- `hlint` - Haskell linter
- `hpack` - Convert package.yaml to .cabal
- `ormolu` - Haskell formatter
- `stylish-haskell` - Haskell formatter

### Language-Specific: Shell
- `beautysh` - Shell formatter
- `shellcheck` - Shell script linter
- `shfmt` - Shell formatter

### Language-Specific: Other Languages
- `clang-format` - C/C++/Java/JavaScript formatter
- `clang-tidy` - C/C++ static analyzer
- `cljfmt` - Clojure formatter
- `cmake-format` - CMake formatter
- `crystal` - Crystal formatter
- `cspell` - Spell checker for code
- `dart-analyze` - Dart analyzer
- `dart-format` - Dart formatter
- `dhall-format` - Dhall formatter
- `dune-fmt` - OCaml Dune formatter
- `elm-format` - Elm formatter
- `elm-review` - Elm linter
- `juliaformatter` - Julia formatter
- `lua-ls` - Lua language server diagnostics
- `luacheck` - Lua linter
- `ocp-indent` - OCaml indenter
- `php-cs-fixer` - PHP formatter
- `phpcbf` - PHP code beautifier
- `phpcs` - PHP linter
- `phpstan` - PHP static analyzer
- `purs-tidy` - PureScript formatter
- `selene` - Lua linter
- `stylua` - Lua formatter
- `zprint` - Clojure formatter

### Markup & Documentation
- `chktex` - LaTeX checker
- `comrak` - CommonMark formatter
- `lacheck` - LaTeX checker
- `latexindent` - LaTeX indenter
- `lychee` - Link checker
- `markdownlint` - Markdown linter
- `mdformat` - Markdown formatter
- `mdl` - Markdown linter
- `mdsh` - Markdown shell preprocessor
- `prettier` - Multi-format formatter (Markdown, HTML, JSON, YAML, CSS)
- `proselint` - Prose linter
- `rumdl` - Markdown linter
- `typos` - Spell checker
- `vale` - Prose linter

### Configuration Files
- `actionlint` - GitHub Actions linter
- `check-json` - JSON syntax checker
- `check-toml` - TOML syntax checker
- `check-xml` - XML syntax checker
- `check-yaml` - YAML syntax checker
- `circleci` - CircleCI config validator
- `cue-fmt` - CUE formatter
- `openapi-spec-validator` - OpenAPI spec validator
- `pretty-format-json` - JSON formatter
- `taplo` - TOML formatter
- `terraform-format` - Terraform formatter
- `terraform-validate` - Terraform validator
- `tflint` - Terraform linter
- `topiary` - Tree-sitter formatter (JSON, TOML, OCaml)
- `treefmt` - Multi-formatter orchestrator
- `woodpecker-cli-lint` - Woodpecker CI linter
- `yamlfmt` - YAML formatter
- `yamllint` - YAML linter

### Git & Commits
- `commitizen` - Commit message checker
- `conform` - Commit policy enforcer
- `convco` - Conventional commits checker
- `gitlint` - Git commit message linter
- `gptcommit` - GPT-generated commit messages
- `no-commit-to-branch` - Prevent commits to specific branches
- `trufflehog` - Secret scanner

### Security & Quality
- `checkmake` - Makefile linter
- `codespell` - Spell checker
- `eclint` - EditorConfig checker
- `editorconfig-checker` - EditorConfig validator
- `pre-commit-hook-ensure-sops` - Ensure SOPS encryption
- `reuse` - REUSE compliance checker
- `ripsecrets` - Secret scanner
- `tagref` - Cross-reference checker

### Package Management
- `poetry-check` - Poetry config checker
- `poetry-lock` - Poetry lockfile updater
- `uv-check` - UV lockfile checker
- `uv-lock` - UV lockfile updater
- `uv-export` - UV lockfile exporter

### Testing
- `bats` - Bash unit tests
- `elm-test` - Elm tests
- `gotest` - Go tests
- `mix-test` - Elixir tests

### Other Tools
- `ansible-lint` - Ansible linter
- `cabal-fmt` - Haskell Cabal formatter
- `cabal-gild` - Haskell Cabal formatter
- `chart-testing` - Helm chart linter
- `flake-checker` - Nix flake health checker
- `headache` - Source file header manager
- `hledger-fmt` - Accounting file formatter
- `hunspell` - Spell checker
- `keep-sorted` - Keep sorted sections
- `nbstripout` - Strip Jupyter notebook output
- `opam-lint` - OCaml package manager linter
- `psalm` - PHP static analyzer
- `sort-file-contents` - Sort file contents
- `sort-requirements-txt` - Sort Python requirements
- `sort-simple-yaml` - Sort simple YAML
- `typstyle` - Typst formatter
- `zizmor` - GitHub Actions security analyzer

## Common Patterns

### Minimal Setup

```nix
# Use prek
git-hooks.package = pkgs.prek;

git-hooks.hooks = {
  # Format code
  nixfmt-rfc-style.enable = true;

  # Check for issues
  shellcheck.enable = true;
  trim-trailing-whitespace.enable = true;
  end-of-file-fixer.enable = true;
};
```

### Python Project

```nix
# Use prek
git-hooks.package = pkgs.prek;

git-hooks.hooks = {
  # Formatters
  ruff-format.enable = true;

  # Linters
  ruff = {
    enable = true;
    entry = "ruff check --fix";
  };

  # Type checking
  mypy.enable = true;

  # Pre-push only (slower checks)
  python-debug-statements = {
    enable = true;
    stages = [ "pre-push" ];
  };
};
```

### Frontend Project

```nix
# Use prek
git-hooks.package = pkgs.prek;

git-hooks.hooks = {
  # Format everything
  prettier = {
    enable = true;
    excludes = [ ".*\\.lock" "dist/" ];
  };

  # Lint JavaScript
  eslint = {
    enable = true;
    entry = "${pkgs.nodePackages.eslint}/bin/eslint --fix";
  };

  # Format Elm
  elm-format.enable = true;
};
```

### Fullstack Project

```nix
# Use prek
git-hooks.package = pkgs.prek;

git-hooks.hooks = {
  # Nix
  nixfmt-rfc-style.enable = true;
  deadnix.enable = true;
  statix.enable = true;

  # Shell
  shellcheck.enable = true;

  # Python (backend)
  ruff.enable = true;
  ruff-format.enable = true;

  # Elm (frontend)
  elm-format.enable = true;
  elm-review.enable = true;

  # General
  trim-trailing-whitespace.enable = true;
  end-of-file-fixer = {
    enable = true;
    excludes = [ ".*\\.svg" "dist/" ];
  };

  # Config files
  prettier = {
    enable = true;
    types_or = [ "json" "yaml" "markdown" ];
  };
  yamlfmt.enable = true;
};
```

### Custom Hooks

For project-specific checks:

```nix
# Use prek
git-hooks.package = pkgs.prek;

git-hooks.hooks = {
  # Custom validation hook
  no-orm-alembic = {
    enable = true;
    name = "No ORM in Alembic";
    description = "Check that ORM is not used in Alembic migrations";
    entry = "bash -c 'grep -ir \"from sqlalchemy import orm\" \"$@\"; test $? -eq 1' --";
    language = "system";
    files = "^backend/src/hakuto/db/versions/.*";
    types = [ "python" ];
  };
};
```

## Hook Configuration Details

### File Matching

```nix
hooks.myHook = {
  # Match by extension pattern
  files = "\\.py$";

  # Multiple patterns (OR)
  files = "(\\.py$)|(\\.pyi$)";

  # Exclude patterns
  excludes = [
    "generated/"
    ".*\\.lock"
    ".*\\.patch"
  ];

  # Match by file type
  types = [ "python" ];
  types_or = [ "javascript" "jsx" "ts" "tsx" ];
};
```

### Stage Control

```nix
hooks.myHook = {
  # Default: pre-commit
  stages = [ "pre-commit" ];

  # Only on push (for expensive checks)
  stages = [ "pre-push" ];

  # Multiple stages
  stages = [ "pre-commit" "pre-push" "manual" ];

  # All available stages:
  # - pre-commit
  # - pre-push
  # - prepare-commit-msg
  # - commit-msg
  # - post-commit
  # - manual
};
```

### Settings Configuration

Many hooks support custom settings:

```nix
hooks.ruff = {
  enable = true;
  settings = {
    # Ruff-specific settings would go here
    # (varies by hook)
  };
};

hooks.prettier = {
  enable = true;
  settings = {
    write = true;
    print-width = 100;
    tab-width = 2;
    use-tabs = false;
  };
};

hooks.deadnix = {
  enable = true;
  settings = {
    edit = false;  # Don't modify files in place
    noLambdaArg = true;
    excludes = [ "nix/sources\\.nix" ];
  };
};
```

### Command Customization

For hooks that need custom commands:

```nix
hooks.ruff = {
  enable = true;
  name = "Ruff linter with auto-fix";
  entry = "bash -c 'cd backend && ${pkgs.ruff}/bin/ruff check --fix .'";
  files = "^backend/";
  types = [ "python" ];
  pass_filenames = false;
};
```

## Working Directory Management

Some tools need to run from specific directories:

```nix
hooks.elm-review = {
  enable = true;
  entry = "bash -c 'cd frontend && ${pkgs.elmPackages.elm-review}/bin/elm-review'";
  files = "^frontend/.*\\.elm";
  pass_filenames = false;
};
```

## Integration with devenv

### Full Example

```nix
{ pkgs, ... }:

{
  packages = with pkgs; [
    # Tools for custom hooks
    codespell
    vacuum-go
  ];

  # Use prek for git hooks
  git-hooks.package = pkgs.prek;

  git-hooks.hooks = {
    # Built-in Nix hooks
    nixfmt-rfc-style.enable = true;
    deadnix = {
      enable = true;
      excludes = [ "nix/sources\\.nix" ];
    };
    statix = {
      enable = true;
      excludes = [ "nix/sources\\.nix" ];
    };

    # Built-in general hooks
    check-merge-conflicts.enable = true;
    end-of-file-fixer = {
      enable = true;
      excludes = [ ".*\\.svg" "frontend/src/Api.*" ];
    };
    trim-trailing-whitespace.enable = true;

    # Built-in Python hooks
    python-debug-statements = {
      enable = true;
      stages = [ "pre-push" ];
    };

    # Custom tool hooks
    codespell = {
      enable = true;
      entry = "${pkgs.codespell}/bin/codespell --ignore-words=.aspell.en.pws";
      excludes = [ ".*\\.lock" ];
    };

    # Backend: Python with working directory
    ruff = {
      enable = true;
      entry = "bash -c 'cd backend && ${pkgs.ruff}/bin/ruff check --fix .'";
      files = "^backend/";
      types = [ "python" ];
      pass_filenames = false;
    };

    # Frontend: Elm
    elm-format = {
      enable = true;
      entry = "${pkgs.elmPackages.elm-format}/bin/elm-format --yes";
      files = "^frontend/.*\\.elm";
      excludes = [ "^frontend/\\.elm-land/" ];
    };
  };
}
```

## Installing Hooks (Automatic via prek)

Devenv with prek handles everything automatically:

```bash
# Just enter the shell - prek installs hooks automatically
devenv shell
```

That's it! prek has:
- ✅ Installed all hooks configured in devenv.nix
- ✅ Set up .git/hooks/ with appropriate scripts
- ✅ Configured hook execution and caching

### Manual Control (if needed)

```bash
# Run all hooks manually
devenv shell --command "pre-commit run --all-files"

# Run specific hook
devenv shell --command "pre-commit run ruff --all-files"

# Skip hooks for a single commit (use sparingly)
git commit --no-verify -m "message"
```

**Note:** Unlike traditional pre-commit, you don't need to run `pre-commit install` - prek handles this automatically through devenv.

## Troubleshooting

### Hook Not Running

**Problem:** Hook enabled but not executing

**Solution:**
```bash
# Check hook is installed
cat .git/hooks/pre-commit

# Reinstall hooks
rm -rf .git/hooks/pre-commit
devenv shell --command "pre-commit install"

# Test manually
devenv shell --command "pre-commit run --all-files"
```

### Wrong Files Matched

**Problem:** Hook running on wrong files

**Solution:**
```nix
hooks.myHook = {
  # Add explicit file pattern
  files = "^backend/.*\\.py$";

  # Or exclude patterns
  excludes = [ "generated/" "tests/fixtures/" ];
};
```

### Hook Failing

**Problem:** Hook exits with error

**Solution:**
```bash
# Run with verbose output
devenv shell --command "pre-commit run --verbose --all-files"

# Debug specific hook
devenv shell --command "pre-commit run myhook --verbose --all-files"
```

### Performance Issues

**Problem:** Hooks too slow

**Solution:**
```nix
hooks.expensive-check = {
  enable = true;
  # Move to pre-push instead of pre-commit
  stages = [ "pre-push" ];
};

hooks.mypy = {
  enable = true;
  # Only run on Python files
  files = "\\.py$";
  # Don't pass individual files (faster for mypy)
  pass_filenames = false;
};
```

## Best Practices

### 1. Use Built-in Hooks First

Always prefer built-in hooks over custom implementations:

```nix
# Good
hooks.trim-trailing-whitespace.enable = true;

# Avoid
hooks.trim-whitespace = {
  enable = true;
  entry = "${pkgs.pre-commit-hooks}/bin/trailing-whitespace-fixer";
  language = "system";
};
```

### 2. Stage Appropriately

Put expensive checks on pre-push:

```nix
git-hooks.hooks = {
  # Fast checks: pre-commit
  ruff-format.enable = true;

  # Slow checks: pre-push
  mypy = {
    enable = true;
    stages = [ "pre-push" ];
  };

  check-added-large-files = {
    enable = true;
    stages = [ "pre-push" ];
  };
};
```

### 3. Configure Exclusions

Exclude generated or vendored code:

```nix
hooks.myHook = {
  enable = true;
  excludes = [
    ".*\\.lock"        # Lock files
    ".*\\.patch"       # Patches
    "generated/"       # Generated code
    "vendor/"          # Vendored dependencies
    "frontend/src/Api.*"  # API clients
  ];
};
```

### 4. Group Related Hooks

Organize by language or purpose:

```nix
git-hooks.hooks = {
  # Nix formatting
  nixfmt-rfc-style.enable = true;
  deadnix.enable = true;
  statix.enable = true;

  # Python backend
  ruff.enable = true;
  ruff-format.enable = true;
  mypy.enable = true;

  # General files
  trim-trailing-whitespace.enable = true;
  end-of-file-fixer.enable = true;
};
```

### 5. Document Custom Hooks

Add comments for non-obvious hooks:

```nix
# Custom Alembic validation hooks
# Alembic migrations should not use ORM or import models
# to avoid circular dependencies and migration issues
no-orm-alembic = {
  enable = true;
  name = "No ORM in Alembic";
  entry = "bash -c 'grep -ir \"from sqlalchemy import orm\" \"$@\"; test $? -eq 1' --";
  files = "^backend/src/hakuto/db/versions/.*";
};
```

## Migration Checklist

When migrating from manual pre-commit setup:

- [ ] Add `git-hooks.package = pkgs.prek;` to devenv.nix
- [ ] Remove `.pre-commit-config.yaml` (devenv manages this)
- [ ] Remove `python313Packages.pre-commit-hooks` from packages
- [ ] Convert hook definitions to use built-in hooks
- [ ] Remove explicit `entry` and `language` when using built-in hooks
- [ ] Fix hook names (e.g., `debug-statements` → `python-debug-statements`)
- [ ] Test with `devenv shell --command "pre-commit run --all-files"`
- [ ] Commit changes and verify hooks run automatically

## Summary

**Key takeaways:**
- Add `git-hooks.package = pkgs.prek;` to use prek (REQUIRED)
- Use built-in hooks whenever possible (just `.enable = true`)
- 171 hooks available covering most languages and tools
- Configure with `git-hooks.hooks.*` in devenv.nix
- Hooks auto-install when entering devenv shell
- Stage expensive checks as `pre-push` instead of `pre-commit`
- Exclude generated/vendored files with `excludes`

**Common built-in hooks:**
- General: `trim-trailing-whitespace`, `end-of-file-fixer`, `check-merge-conflicts`
- Nix: `nixfmt-rfc-style`, `deadnix`, `statix`
- Python: `ruff`, `ruff-format`, `black`, `mypy`, `python-debug-statements`
- JavaScript: `prettier`, `eslint`, `biome`
- Shell: `shellcheck`, `shfmt`
- Configs: `yamlfmt`, `yamllint`, `taplo`, `prettier`
