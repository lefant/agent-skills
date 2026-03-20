# Migration Guide: nix-shell to devenv

## Why Migrate to devenv?

**devenv** provides declarative, reproducible development environments with significant advantages over traditional nix-shell:

- **Integrated service management**: PostgreSQL, Redis, MySQL run as managed processes
- **Process orchestration**: Replace process-compose.yml with declarative process definitions
- **Better isolation**: Services use project-local data directories
- **Simplified configuration**: Single devenv.nix replaces shell.nix + default.nix + process-compose.yml
- **Automatic environment activation**: Works seamlessly with direnv
- **Pre-commit integration**: Declarative git hooks without manual setup
- **Task system**: Define build, test, and deployment tasks alongside environment

## Quick Start

### Install devenv

```bash
# With Nix flakes enabled
nix profile install nixpkgs#devenv

# Verify installation
devenv version
```

### Initialize New Project

```bash
cd your-project
devenv init
# Creates: devenv.nix, devenv.yaml, .envrc
```

### Enter Environment

```bash
# One-time activation
devenv shell

# Or use direnv for automatic activation
direnv allow
```

## Basic Conversion Patterns

### mkShell to devenv.nix

**Before (shell.nix):**
```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python313
    postgresql_17
    redis
  ];

  shellHook = ''
    echo "Welcome to dev environment"
    export DATABASE_URL="postgresql:///mydb"
  '';
}
```

**After (devenv.nix):**
```nix
{ pkgs, ... }:

{
  packages = with pkgs; [
    # Add non-language tools here
  ];

  languages.python = {
    enable = true;
    version = "3.13";
  };

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_17;
    initialDatabases = [{ name = "mydb"; }];
  };

  services.redis.enable = true;

  env.DATABASE_URL = "postgresql:///mydb?host=$PGHOST";

  enterShell = ''
    echo "Welcome to dev environment"
  '';
}
```

**Key Changes:**
- `buildInputs` → `packages` (for tools) and `languages.*` (for language runtimes)
- `shellHook` → `enterShell`
- Services get declarative configuration instead of manual setup
- Environment variables in `env.*` instead of export statements

### Converting buildInputs

**Language runtimes** move to `languages.*`:
- `python313` → `languages.python.enable = true; languages.python.version = "3.13";`
- `nodejs_22` → `languages.javascript.enable = true; languages.javascript.package = pkgs.nodejs_22;`
- `go` → `languages.go.enable = true;`
- `elmPackages.elm` → `languages.elm.enable = true;`

**Services** move to `services.*`:
- `postgresql_17` → `services.postgres.enable = true; services.postgres.package = pkgs.postgresql_17;`
- `redis` → `services.redis.enable = true;`
- `mysql80` → `services.mysql.enable = true; services.mysql.package = pkgs.mysql80;`

**Tools and utilities** stay in `packages`:
- Build tools (make, cmake, etc.)
- CLI utilities (jq, ripgrep, fd, etc.)
- Formatters and linters (ruff, prettier, etc.)
- Version control (git, gh, etc.)

### Converting shellHook to enterShell

**Simple conversions:**
```nix
# Before
shellHook = ''
  export DJANGO_SETTINGS_MODULE=myapp.settings.dev
  echo "Dev environment ready"
'';

# After
env.DJANGO_SETTINGS_MODULE = "myapp.settings.dev";
enterShell = ''
  echo "Dev environment ready"
'';
```

**Complex shell initialization:**
```nix
# Before: Python venv setup in shellHook
shellHook = ''
  if [ ! -d .venv ]; then
    python -m venv .venv
  fi
  source .venv/bin/activate
  pip install -r requirements.txt
'';

# After: Use devenv's Python support
languages.python = {
  enable = true;
  venv.enable = true;  # Creates and activates venv automatically
  venv.requirements = ./requirements.txt;
};

# Or with uv (better approach):
languages.python = {
  enable = true;
  uv.enable = true;
};

enterShell = ''
  uv sync --dev
'';
```

## Flakes Integration

### Converting Flake-Based Setups

**Before (flake.nix):**
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ python313 postgresql_17 ];
        };
      }
    );
}
```

**After (devenv.yaml + devenv.nix):**

devenv.yaml:
```yaml
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixos-unstable
```

devenv.nix:
```nix
{ pkgs, ... }:

{
  languages.python.enable = true;
  services.postgres.enable = true;
  services.postgres.package = pkgs.postgresql_17;
}
```

**Locked inputs:** devenv uses `devenv.lock` (auto-generated) similar to flake.lock.

### Using Multiple Nixpkgs Channels

**Hakuto pattern** (using stable + unstable channels):

devenv.yaml:
```yaml
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixos-24.11
  nixpkgs-unstable:
    url: github:NixOS/nixpkgs/nixos-unstable
```

devenv.nix:
```nix
{ pkgs, inputs, ... }:

{
  # Use stable packages by default
  packages = with pkgs; [
    jq
    ripgrep
  ];

  # Use unstable for specific packages
  languages.python.package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.python313;
}
```

## Complex Migrations

### Multi-Language Stack (Hakuto Example)

**Before: Hakuto's default.nix** (150+ lines)
- Python backend with uv
- Elm frontend with elm-land
- PostgreSQL 17 + Redis services
- OpenAPI client generation
- Platform-specific patchelf logic
- Pre-commit hooks

**After: devenv.nix** (~80-100 lines)

```nix
{ pkgs, config, ... }:

{
  packages = with pkgs; [
    # Project-wide tools
    git
    gh
    jq

    # Linters and formatters
    ruff
    nixfmt-rfc-style
    yamlfmt

    # Frontend build tools
    tailwindcss
    nodePackages.prettier
    nodePackages.eslint
  ];

  # Backend: Python with uv (automatic venv + patchelf)
  languages.python = {
    enable = true;
    version = "3.13";
    directory = "./backend";  # Where pyproject.toml lives
    uv = {
      enable = true;
      sync.enable = true;  # Auto-sync on shell entry
    };
  };

  # Frontend: Elm
  languages.elm.enable = true;
  packages = [ pkgs.elm-land ];

  # Services
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_17;
    initialDatabases = [{ name = "hakuto_dev"; }];
    listen_addresses = "127.0.0.1";
  };

  services.redis = {
    enable = true;
    port = 6379;
  };

  # Pre-commit hooks
  pre-commit.hooks = {
    ruff.enable = true;
    ruff-format.enable = true;
    nixfmt-rfc-style.enable = true;
    yamlfmt.enable = true;
  };

  # Processes (replaces process-compose.yml)
  processes = {
    backend = {
      exec = "cd backend && uvicorn hakuto.app:app --reload";
      process-compose = {
        depends_on = {
          postgres.condition = "process_healthy";
          redis.condition = "process_healthy";
        };
      };
    };

    frontend-dev = {
      exec = "cd frontend && elm-land server --watch";
    };

    frontend-css = {
      exec = "cd frontend && tailwindcss -i ./src/style.css -o ./static/style.css --watch";
    };
  };

  # Tasks (replaces Makefile targets)
  scripts = {
    generate-api-client.exec = ''
      openapi-generator-cli generate \
        --input-spec backend/src/hakuto/openapi.yaml \
        --generator-name elm \
        --config frontend/openapi-generator.yml \
        --output frontend/src/
      elm-format --yes frontend/src/
    '';

    test.exec = ''
      cd backend && pytest
    '';

    devdb.exec = ''
      cd backend && python -m hakuto.scripts.devdb
    '';
  };

  # Environment variables
  env = {
    DATABASE_URL = "postgresql:///hakuto_dev?host=$PGHOST";
    REDIS_URL = "redis://127.0.0.1:6379";
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
  };

  enterShell = ''
    # OpenAPI client generation on shell entry
    generate-api-client

    # Frontend build
    (cd frontend && make dist)
  '';

  # Note: Python uv.sync.enable handles venv activation and Linux patchelf automatically
}
```

**Benefits of conversion:**
- Single configuration file vs 3+ files
- Declarative service management (auto-start/stop)
- Integrated process orchestration
- Platform-specific logic contained in one place
- Pre-commit hooks without manual installation

### Custom Derivations

**Before: OpenAPI client generation**
```nix
openapi-client = pkgs.runCommand "openapi-client" {
  buildInputs = with pkgs; [ openapi-generator-cli elmPackages.elm-format ];
} ''
  openapi-generator-cli generate \
    --input-spec ${./backend/src/hakuto/openapi.yaml} \
    --generator-name elm \
    --output "$out"
  elm-format --yes $out/src/
'';
```

**After: Use scripts + enterShell**
```nix
scripts.generate-api-client.exec = ''
  openapi-generator-cli generate \
    --input-spec backend/src/hakuto/openapi.yaml \
    --generator-name elm \
    --output frontend/src/
  elm-format --yes frontend/src/
'';

enterShell = ''
  generate-api-client
'';
```

**When to keep derivations:**
- Building distributable artifacts (frontend dist build)
- Dependency on derivation output in other derivations
- CI/CD build steps

**When to use scripts:**
- Development-time code generation
- Local file manipulation
- Tasks that reference project files directly

## Step-by-Step Migration Process

### 1. Initial Setup

```bash
cd your-project

# Install devenv if not already installed
nix profile install nixpkgs#devenv

# Initialize devenv (creates devenv.nix, devenv.yaml, .envrc)
devenv init
```

### 2. Analyze Current Setup

Identify what needs migration:
- [ ] Languages and tools (shell.nix buildInputs)
- [ ] Services (PostgreSQL, Redis, MySQL, etc.)
- [ ] Process orchestration (process-compose.yml, Procfile, etc.)
- [ ] Shell initialization (shellHook scripts)
- [ ] Environment variables
- [ ] Pre-commit hooks
- [ ] Flake inputs (if using flakes)

### 3. Convert Configuration

**Start with languages:**
```nix
# Shell.nix had: python313, nodejs_22, go
languages.python.enable = true;
languages.javascript.enable = true;
languages.go.enable = true;
```

**Add tools to packages:**
```nix
packages = with pkgs; [
  jq
  ripgrep
  postgresql_17  # CLI tools, not service
];
```

**Convert services:**
```nix
# Process-compose had: postgresql, redis
services.postgres.enable = true;
services.redis.enable = true;
```

**Migrate shellHook logic:**
```nix
# Simple exports → env.*
env.DATABASE_URL = "postgresql:///mydb?host=$PGHOST";

# Complex initialization → enterShell
enterShell = ''
  echo "Environment ready"
  make setup  # Run project-specific setup
'';
```

### 4. Test the Environment

```bash
# Enter the environment
devenv shell

# Verify languages
python --version
node --version

# Check services
psql -l  # Should list databases
redis-cli ping  # Should return PONG

# Test processes
devenv up  # Start all processes
```

### 5. Iterate and Refine

Common issues during migration:
- **Service ports conflict**: Change ports in `services.*.port`
- **Database initialization**: Add `initialDatabases` or `initialScript`
- **Environment variables**: Missing vars break apps - verify all are migrated
- **Python venv**: Remove manual venv setup, use `languages.python.venv.enable`
- **Pre-commit hooks**: Convert from manual install to `pre-commit.hooks.*`

### 6. Clean Up

After successful migration:
```bash
# Remove old files
rm shell.nix default.nix
rm process-compose.yml  # If fully converted to devenv processes

# Update documentation
# Update .gitignore: add .devenv, .direnv
echo ".devenv/" >> .gitignore
echo ".direnv/" >> .gitignore

# Commit changes
git add devenv.nix devenv.yaml .envrc .gitignore
git commit -m "Migrate from nix-shell to devenv"
```

## Migration Checklist

Use this checklist to ensure complete migration:

- [ ] devenv.nix created with all languages configured
- [ ] All buildInputs migrated (languages, tools, packages)
- [ ] Services running (postgres, redis, etc.)
- [ ] Processes defined (dev servers, watchers, etc.)
- [ ] Environment variables migrated
- [ ] Shell initialization logic works (enterShell, enterTest)
- [ ] Pre-commit hooks configured
- [ ] Scripts/tasks defined for common operations
- [ ] Platform-specific logic handled (Linux patchelf, etc.)
- [ ] Flake inputs migrated to devenv.yaml (if applicable)
- [ ] Documentation updated
- [ ] Old files removed (shell.nix, default.nix, etc.)
- [ ] Team members can successfully use new setup

## Common Pitfalls

### 1. Forgetting to Enable direnv

devenv works best with direnv for automatic activation:
```bash
# Add to .envrc
use devenv

# Enable direnv
direnv allow
```

### 2. Service Data Persistence

devenv services use local data directories (`.devenv/state/postgres`, etc.). These are gitignored by default. To reset services:
```bash
rm -rf .devenv/state
devenv up  # Services will reinitialize
```

### 3. Python uv in Monorepo Projects

Automatic `uv.sync.enable` doesn't work in monorepo layouts where `pyproject.toml` is in a subdirectory:
```nix
# Bad: Automatic sync fails in monorepo
languages.python = {
  enable = true;
  uv = {
    enable = true;
    sync.enable = true;  # Runs from root, can't find backend/pyproject.toml
  };
};

# Good: Manual sync from correct directory
languages.python = {
  enable = true;
  version = "3.13";
};

packages = [ pkgs.uv ];

enterShell = ''
  # Sync from subdirectory where pyproject.toml lives
  (cd backend && uv sync --dev)
'';
```

**Monorepo structure example:**
```
project/
├── backend/
│   ├── pyproject.toml  ← Python project here
│   └── uv.lock
├── frontend/           ← Frontend code here
└── devenv.nix          ← devenv runs from here
```

### 4. Hardcoded Paths

Don't hardcode paths to services:
```nix
# Bad
env.DATABASE_URL = "postgresql:///mydb?host=/tmp/.s.PGSQL.5432";

# Good: Use $PGHOST which devenv sets
env.DATABASE_URL = "postgresql:///mydb?host=$PGHOST";
```

### 5. Code Generation Order (enterTest vs enterShell)

Generated code must exist before dependent builds run:
```nix
# Bad: Generate in enterShell - frontend build might run first
enterShell = ''
  openapi-gen  # Generates API.elm
  make frontend-build  # Needs API.elm - RACE CONDITION!
'';

# Good: Generate in enterTest - runs BEFORE enterShell
enterTest = ''
  # Code generation runs first
  openapi-generator-cli generate ...
  elm-format ...
  cp generated files...
'';

enterShell = ''
  # Now frontend build can safely use generated code
  if [[ ! -d frontend/dist ]]; then
    make frontend-build
  fi
'';
```

**Execution order:**
1. `enterTest` - Build-time tasks (code generation, asset compilation)
2. `enterShell` - Runtime setup (env activation, welcome messages)

### 6. Missing Service Dependencies

Processes must declare dependencies on services:
```nix
processes.backend = {
  exec = "uvicorn app:app --reload";
  process-compose = {
    depends_on = {
      postgres.condition = "process_healthy";
    };
  };
};
```

### 7. PostgreSQL initialScript Quoting

SQL empty strings conflict with Nix multi-line string syntax:
```nix
# Bad: Syntax error!
services.postgres.initialScript = ''
  CREATE USER myuser WITH PASSWORD '';  ← Nix sees '' as string end
'';

# Good: Escape quotes with ''''
services.postgres.initialScript = ''
  CREATE USER myuser WITH PASSWORD '''';  ← Escaped
'';
```

### 8. process-compose Environment Format

Environment variables must be a list of strings, not a map:
```nix
processes.myapp = {
  exec = "npm start";
  process-compose = {
    # Bad: Nix attribute set
    environment = {
      DEBUG = "true";
      NODE_ENV = "development";
    };

    # Good: List of "KEY=VALUE" strings
    environment = [
      "DEBUG=true"
      "NODE_ENV=development"
    ];
  };
};
```

## Next Steps

After migration:
- **Optimize**: Remove unused packages, simplify configuration
- **Document**: Update README with devenv setup instructions
- **CI/CD**: Integrate devenv in CI pipelines (`devenv ci`)
- **Share**: Commit devenv.lock for reproducible environments across team

## Further Reading

- [Language Configurations](./language-configs.md) - Python, Elm, JavaScript, Go patterns
- [Services Guide](./services-guide.md) - PostgreSQL, Redis, MySQL setup
- [Processes and Tasks](./processes-tasks.md) - Process orchestration and scripts
- [Troubleshooting](./troubleshooting.md) - Common issues and solutions
