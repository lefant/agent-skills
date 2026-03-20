# Language Configurations

## Python

### Basic Setup

```nix
{ pkgs, ... }:

{
  languages.python = {
    enable = true;
    version = "3.13";  # or "3.12", "3.11", etc.
  };
}
```

This provides:
- Python interpreter at specified version
- pip, setuptools, wheel
- Virtual environment support

### Virtual Environments

**Automatic venv with requirements.txt:**
```nix
languages.python = {
  enable = true;
  venv.enable = true;
  venv.requirements = ./requirements.txt;
};
```

On shell entry:
- Creates `.venv/` if not exists
- Installs packages from requirements.txt
- Activates venv automatically

**Automatic venv with quiet mode:**
```nix
languages.python = {
  enable = true;
  venv = {
    enable = true;
    quiet = true;  # Suppress venv creation output
  };
};
```

### uv Integration (Recommended)

**uv** is a fast Python package installer and resolver, ideal for modern Python projects.

**Recommended: Use directory + sync (automatic everything):**
```nix
languages.python = {
  enable = true;
  version = "3.13";
  directory = "./backend";  # Where pyproject.toml lives
  uv = {
    enable = true;
    sync.enable = true;  # Auto-runs 'uv sync' on shell entry
  };
};
```

This automatically:
- ✅ Runs `uv sync` when entering shell
- ✅ Activates the virtual environment
- ✅ Handles patchelf on Linux (no manual patching needed!)
- ✅ Manages PYTHONPATH correctly
- ✅ Exports VIRTUAL_ENV for tools

**For monorepo/subdirectory projects:**
```nix
languages.python = {
  enable = true;
  directory = "./backend";  # Point to subdirectory with pyproject.toml
  uv = {
    enable = true;
    sync = {
      enable = true;
      allExtras = true;  # Install all optional dependencies
    };
  };
};
```

**Manual uv sync (if you need custom flags):**
```nix
languages.python = {
  enable = true;
  uv.enable = true;
};

enterShell = ''
  uv sync --dev --all-extras
'';
```

### Poetry Integration

```nix
languages.python = {
  enable = true;
  poetry = {
    enable = true;
    activate.enable = true;  # Auto-activate poetry env
    install.enable = true;   # Run 'poetry install' on shell entry
  };
};
```

### PYTHONPATH Management

**Problem:** nixpkgs may pollute PYTHONPATH with system Python packages, causing import conflicts.

**Solution:**
```nix
languages.python.enable = true;

enterShell = ''
  # Clear nixpkgs Python paths
  unset PYTHONPATH
'';
```

**When you need to add to PYTHONPATH:**
```nix
env.PYTHONPATH = "${toString ./.}/backend/src:$PYTHONPATH";
```

### Development Tools

**Include Python dev tools in environment:**
```nix
{ pkgs, ... }:

{
  languages.python = {
    enable = true;
    version = "3.13";
  };

  packages = with pkgs; [
    # Linters and formatters
    ruff
    black
    mypy

    # Testing
    python313Packages.pytest
    python313Packages.coverage

    # Tools
    python313Packages.ipython
  ];
}
```

**Note:** It's often better to install dev tools via uv/pip in the venv for consistency across team members.

### Playwright and Browser Dependencies

Hakuto uses Playwright for end-to-end testing:

```nix
{ pkgs, ... }:

{
  languages.python = {
    enable = true;
    uv.enable = true;
  };

  packages = [ pkgs.playwright-driver ];

  env.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";

  enterShell = ''
    uv sync --dev
    source .venv/bin/activate
  '';
}
```

### Platform-Specific: Linux patchelf

**If using `directory` + `uv.sync.enable`:** devenv handles patchelf automatically - no manual patching needed!

**Only needed for manual venv management:**
```nix
{ pkgs, config, ... }:

{
  languages.python = {
    enable = true;
    uv.enable = true;
  };

  enterShell = ''
    # Manual sync without directory option
    uv sync --dev
    source .venv/bin/activate
  '';

  # Manual patchelf for Linux (only if NOT using directory + sync.enable)
  enterTest = pkgs.lib.optionalString pkgs.stdenv.isLinux ''
    if [ -d .venv ] && [ ! -f .venv/.patched ]; then
      find .venv -name "*.so" -type f | while read -r so_file; do
        patchelf --set-rpath "${pkgs.stdenv.cc.cc.lib}/lib:$(patchelf --print-rpath "$so_file" 2>/dev/null || true)" "$so_file" 2>/dev/null || true
      done
      touch .venv/.patched
    fi
  '';
}
```

**When patchelf is needed:**
- NixOS or Nix on Linux
- Python packages with C extensions (numpy, pandas, psycopg2, etc.)
- Only when NOT using `languages.python.directory` + `uv.sync.enable`

## JavaScript / Node.js

### Basic Setup

```nix
{ pkgs, ... }:

{
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_22;  # or nodejs_20, nodejs_18
  };
}
```

Provides:
- Node.js runtime
- npm package manager

### npm Configuration

**Auto-install dependencies:**
```nix
languages.javascript = {
  enable = true;
  npm = {
    enable = true;
    install.enable = true;  # Runs 'npm install' on shell entry
  };
};
```

### Yarn

```nix
languages.javascript = {
  enable = true;
  yarn = {
    enable = true;
    install.enable = true;  # Runs 'yarn install' on shell entry
  };
};
```

### pnpm

```nix
languages.javascript = {
  enable = true;
  pnpm = {
    enable = true;
    install.enable = true;  # Runs 'pnpm install' on shell entry
  };
};
```

### Additional JavaScript Tools

```nix
{ pkgs, ... }:

{
  languages.javascript.enable = true;

  packages = with pkgs; [
    # Build tools
    nodePackages.typescript
    nodePackages.webpack-cli

    # Linters and formatters
    nodePackages.eslint
    nodePackages.prettier

    # Utilities
    nodePackages.npm-check-updates
  ];
}
```

### Frontend Build Tools

**Hakuto frontend pattern** (Elm with Node tooling):

```nix
packages = with pkgs; [
  # Node-based tools for frontend
  nodePackages.eslint
  nodePackages.prettier
  tailwindcss

  # Create node_modules symlink for ESLint
];

enterShell = ''
  # Symlink node_modules for ESLint to work
  ln -sfn ${pkgs.nodePackages.eslint}/lib/node_modules/eslint/node_modules frontend/node_modules
'';
```

## Elm

### Basic Setup

```nix
{ pkgs, ... }:

{
  languages.elm.enable = true;

  packages = with pkgs; [
    # Additional Elm tools
    elmPackages.elm-format
    elmPackages.elm-review
    elmPackages.elm-test
    elmPackages.elm-json
  ];
}
```

Provides:
- elm compiler
- elm repl
- elm reactor

### Elm Land Integration

**Hakuto uses elm-land** for file-based routing:

```nix
{ pkgs, ... }:

{
  languages.elm.enable = true;

  packages = with pkgs; [
    elm-land
    elmPackages.elm-format
    tailwindcss  # For styling
  ];

  processes = {
    elm-dev = {
      exec = "cd frontend && elm-land server --watch";
    };

    tailwind-watch = {
      exec = "cd frontend && tailwindcss -i ./src/style.css -o ./static/style.css --watch";
    };
  };
}
```

### Elm Package Management

Elm packages are managed in `elm.json`. devenv doesn't need special configuration - `elm-land` and `elm` handle dependencies automatically.

**For locked dependencies (Hakuto pattern with elm-srcs.nix):**
This is typically only needed for advanced Nix builds, not for development environments. devenv's Elm support works with standard elm.json.

## Go

### Basic Setup

```nix
{ pkgs, ... }:

{
  languages.go = {
    enable = true;
    package = pkgs.go_1_22;  # or go_1_21, etc.
  };
}
```

Provides:
- Go compiler and toolchain
- go mod, go build, go test, etc.

### Additional Go Tools

```nix
languages.go.enable = true;

packages = with pkgs; [
  # Development tools
  gopls          # Language server
  gotools        # goimports, godoc, etc.
  go-tools       # staticcheck, etc.
  delve          # Debugger

  # Build tools
  goreleaser
];
```

## Rust

### Basic Setup

```nix
languages.rust = {
  enable = true;
  channel = "stable";  # or "nightly", "beta"
};
```

Provides:
- rustc compiler
- cargo package manager
- rustfmt, clippy

### Rust Toolchain Management

```nix
languages.rust = {
  enable = true;
  channel = "stable";
  components = [ "rustfmt" "clippy" ];
};
```

## Multi-Language Projects

### Python + JavaScript (Fullstack)

```nix
{ pkgs, ... }:

{
  # Backend: Python
  languages.python = {
    enable = true;
    version = "3.13";
    uv.enable = true;
  };

  # Frontend: Node.js
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_22;
    npm.enable = true;
  };

  packages = with pkgs; [
    # Shared tools
    jq
    curl

    # Backend tools
    ruff

    # Frontend tools
    nodePackages.prettier
    nodePackages.eslint
  ];

  enterShell = ''
    # Setup backend
    cd backend && uv sync --dev && cd ..

    # Setup frontend
    cd frontend && npm install && cd ..

    echo "Fullstack environment ready"
  '';
}
```

### Python + Elm (Hakuto Pattern)

```nix
{ pkgs, ... }:

{
  # Backend: Python with uv
  languages.python = {
    enable = true;
    version = "3.13";
    uv.enable = true;
  };

  # Frontend: Elm
  languages.elm.enable = true;

  packages = with pkgs; [
    # Backend tooling
    ruff
    postgresql_17  # CLI tools

    # Frontend tooling
    elm-land
    elmPackages.elm-format
    elmPackages.elm-review
    tailwindcss
    nodePackages.prettier

    # Shared tools
    openapi-generator-cli  # API client generation
    jq
  ];

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_17;
  };

  services.redis.enable = true;

  processes = {
    backend = {
      exec = "cd backend && uvicorn hakuto.app:app --reload";
      process-compose.depends_on = {
        postgres.condition = "process_healthy";
        redis.condition = "process_healthy";
      };
    };

    frontend-dev = {
      exec = "cd frontend && elm-land server --watch";
    };

    frontend-css = {
      exec = "cd frontend && tailwindcss -i ./src/style.css -o ./static/style.css --watch";
    };
  };

  scripts.generate-api-client.exec = ''
    openapi-generator-cli generate \
      --input-spec backend/src/hakuto/openapi.yaml \
      --generator-name elm \
      --output frontend/src/
    elm-format --yes frontend/src/
  '';

  enterShell = ''
    # Generate API client
    generate-api-client

    # Setup backend
    cd backend && uv sync --dev && source .venv/bin/activate && cd ..

    # Build frontend
    cd frontend && make dist && cd ..
  '';
}
```

### Go + JavaScript (API + SPA)

```nix
{ pkgs, ... }:

{
  languages.go.enable = true;

  languages.javascript = {
    enable = true;
    npm.enable = true;
  };

  services.postgres.enable = true;

  processes = {
    api = {
      exec = "go run ./cmd/api";
      process-compose.depends_on.postgres.condition = "process_healthy";
    };

    frontend = {
      exec = "cd frontend && npm run dev";
    };
  };
}
```

## Language-Specific Troubleshooting

### Python: Import Errors

**Symptom:** `ModuleNotFoundError` for packages installed in venv.

**Causes:**
1. venv not activated
2. PYTHONPATH pollution from nixpkgs

**Solutions:**
```nix
# Ensure venv activation
enterShell = ''
  source .venv/bin/activate
'';

# Clear PYTHONPATH
enterShell = ''
  unset PYTHONPATH
  source .venv/bin/activate
'';
```

### Python: uv sync fails

**Symptom:** `uv sync` errors with package resolution issues.

**Solutions:**
- Check pyproject.toml for syntax errors
- Update uv: `nix profile upgrade nixpkgs#uv`
- Clear uv cache: `uv cache clean`

### JavaScript: npm install fails

**Symptom:** Permission errors or EACCES during npm install.

**Causes:**
- npm trying to write to read-only Nix store paths

**Solution:**
```nix
# Use local node_modules
languages.javascript = {
  enable = true;
  npm.enable = true;
};

# Ensure node_modules is in project directory
enterShell = ''
  export npm_config_prefix="$PWD/.npm-global"
'';
```

### Elm: Compilation errors after entering shell

**Symptom:** Elm compiler can't find installed packages.

**Cause:**
- Missing `elm.json` or corrupted `elm-stuff/`

**Solution:**
```bash
rm -rf elm-stuff/
elm make src/Main.elm  # Will re-download packages
```

### Multi-language: PATH conflicts

**Symptom:** Wrong version of python/node/go in PATH.

**Solution:**
```nix
# devenv manages PATH automatically
# Verify which binaries are active:
enterShell = ''
  echo "Python: $(which python)"
  echo "Node: $(which node)"
  echo "Go: $(which go)"
'';
```

## Best Practices

### 1. Pin Language Versions

```nix
# Good: Explicit versions
languages.python.version = "3.13";
languages.javascript.package = pkgs.nodejs_22;

# Avoid: Implicit versions (may change)
languages.python.enable = true;  # Uses default, may update
```

### 2. Separate Dev Dependencies

Install linters/formatters in venv, not in devenv:

```toml
# pyproject.toml
[project.optional-dependencies]
dev = [
    "ruff",
    "mypy",
    "pytest",
    "pytest-cov",
]
```

```nix
# devenv.nix - minimal packages
languages.python = {
  enable = true;
  uv.enable = true;
};

enterShell = ''
  uv sync --dev  # Installs dev dependencies in venv
'';
```

### 3. Document Language Choices

Add comments explaining version choices:

```nix
languages.python = {
  enable = true;
  version = "3.13";  # Required for newer type hints in codebase
};

languages.javascript = {
  enable = true;
  package = pkgs.nodejs_22;  # LTS version, required by tailwindcss 4.x
};
```

### 4. Test Across Platforms

If team uses macOS + Linux:

```nix
enterShell = ''
  echo "Platform: ${pkgs.stdenv.system}"

  ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
    echo "Linux-specific setup..."
  ''}

  ${pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
    echo "macOS-specific setup..."
  ''}
'';
```

## Further Reading

- [Services Guide](./services-guide.md) - Database and service configuration
- [Processes and Tasks](./processes-tasks.md) - Running dev servers and tasks
- [Troubleshooting](./troubleshooting.md) - Platform-specific issues
