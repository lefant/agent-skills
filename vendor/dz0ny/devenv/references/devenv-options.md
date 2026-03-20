# devenv.nix Options Reference

**Official Documentation**: https://github.com/cachix/devenv/blob/main/docs/src/reference/options.md

This is a quick reference for common devenv.nix configuration options. For the complete, up-to-date reference, always consult the official documentation above.

## Core Configuration

### Packages & Environment

```nix
# Packages exposed in the environment
packages = [ pkgs.git pkgs.jq ];

# Environment variables
env.DATABASE_URL = "postgresql:///mydb";
env.API_KEY = "secret";
```

### Shell Hooks

```nix
# Executed when entering the shell
enterShell = ''
  echo "Welcome!"
'';

# Test suite execution
enterTest = ''
  pytest tests/
'';
```

## Language Support

All language configurations follow the pattern: `languages.<lang>.enable = true;`

### Python

**Recommended (automatic venv + patchelf):**
```nix
languages.python = {
  enable = true;
  version = "3.13";
  directory = "./backend";  # Where pyproject.toml lives
  uv = {
    enable = true;
    sync.enable = true;     # Auto-sync on shell entry
    sync.allExtras = true;  # Install all extras
  };
};
```

**Other options:**
```nix
languages.python = {
  enable = true;
  venv.enable = true;      # Auto .venv creation
  poetry.enable = true;    # Use poetry instead of uv
};
```

### JavaScript/Node

```nix
languages.javascript = {
  enable = true;
  npm.enable = true;
  yarn.enable = true;
  pnpm.enable = true;
};
```

### Other Languages

- `languages.rust.enable = true;`
- `languages.go.enable = true;`
- `languages.elixir.enable = true;`
- `languages.elm.enable = true;`
- `languages.php.enable = true;`
- `languages.ruby.enable = true;`
- `languages.java.enable = true;`
- `languages.c.enable = true;`
- `languages.dotnet.enable = true;`

## Services

All service configurations follow the pattern: `services.<service>.enable = true;`

### PostgreSQL

```nix
services.postgres = {
  enable = true;
  package = pkgs.postgresql_17;
  listen_addresses = "127.0.0.1";
  port = 5432;
  initialDatabases = [{ name = "mydb"; }];
  initialScript = "CREATE EXTENSION postgis;";
};
```

### Redis

```nix
services.redis = {
  enable = true;
  port = 6379;
};
```

### MySQL

```nix
services.mysql = {
  enable = true;
  package = pkgs.mysql80;
  settings.mysqld = {
    port = 3306;
  };
  initialDatabases = [{ name = "mydb"; }];
};
```

### Other Services

- `services.mongodb.enable = true;`
- `services.elasticsearch.enable = true;`
- `services.nginx.enable = true;`
- `services.caddy.enable = true;`
- `services.mailpit.enable = true;`
- `services.minio.enable = true;`

## Processes

Long-running development processes (servers, watchers):

```nix
processes.<name> = {
  exec = "command to run";
  process-compose = {
    depends_on.<other-process>.condition = "process_healthy";
    availability.restart = "on_failure";
    readiness_probe = {
      exec.command = "pg_isready -h $PGHOST";
      initial_delay_seconds = 2;
      period_seconds = 10;
      timeout_seconds = 4;
      success_threshold = 1;
      failure_threshold = 5;
    };
  };
};
```

**Common patterns:**
- Use `depends_on` for process ordering
- Use `readiness_probe` for health checks
- Use `availability.restart = "on_failure"` for resilience
- One-time setup tasks: add `&& exit 0` at the end

## Scripts/Tasks

One-time commands (build, test, deploy):

```nix
scripts.<name>.exec = "command to run";

# Examples
scripts.build.exec = "npm run build";
scripts.test.exec = "pytest";
scripts.migrate.exec = "alembic upgrade head";
```

## Git Hooks

Built-in pre-commit hooks (170+ available):

```nix
git-hooks.hooks = {
  # Python
  ruff.enable = true;
  ruff-format.enable = true;
  mypy.enable = true;

  # JavaScript/TypeScript
  eslint.enable = true;
  prettier.enable = true;

  # Rust
  clippy.enable = true;
  rustfmt.enable = true;

  # Shell
  shellcheck.enable = true;
  shfmt.enable = true;

  # Nix
  nixfmt.enable = true;
  statix.enable = true;
};
```

## Integration Features

### Containers

```nix
containers.<name> = {
  copyToRoot = null;  # Defaults to git repo
  entrypoint = [ "command" ];
  workingDir = "/env";
};
```

### Dotenv Support

```nix
dotenv.enable = true;  # Load .env files
```

### Certificates

```nix
certificates = [ "myapp.local" ];  # Uses mkcert
```

### Dev Containers (VS Code)

```nix
devcontainer = {
  enable = true;
  settings.customizations.vscode.extensions = [
    "mkhl.direnv"
  ];
};
```

## Platform-Specific

### macOS

```nix
apple.sdk = pkgs.darwin.apple_sdk_11_0;  # Specify SDK version
```

### Android

```nix
android = {
  enable = true;
  platforms.version = [ "34" ];
  systemImageTypes = [ "google_apis_playstore" ];
};
```

## Advanced Features

### File Generation

```nix
files = {
  ".prettierrc" = {
    json = {
      semi = false;
      singleQuote = true;
    };
  };
  "config.yaml" = {
    yaml = {
      server.port = 8080;
    };
  };
};
```

### Cachix Integration

```nix
cachix = {
  enable = true;
  push = "my-cache";  # Push to this cache
  pull = [ "cache1" "cache2" ];  # Pull from these caches
};
```

### Debug Mode

```nix
devenv.debug = true;  # Enable debug output in enterShell
```

## Common Configuration Patterns

### Full-Stack Web App

```nix
{
  languages.python.enable = true;
  languages.python.uv.enable = true;
  languages.javascript.enable = true;

  services.postgres.enable = true;
  services.redis.enable = true;

  processes.backend.exec = "uvicorn app:app --reload";
  processes.frontend.exec = "npm run dev";

  scripts.migrate.exec = "alembic upgrade head";
  scripts.test.exec = "pytest && npm test";
}
```

### Monorepo Setup

```nix
{
  packages = with pkgs; [ jq yq ];

  languages.python.uv = {
    enable = true;
    package = pkgs.uv;
    sync.enable = true;
    sync.allExtras = true;
  };

  # Workspace-specific processes
  processes.api.exec = "cd api && uvicorn main:app";
  processes.worker.exec = "cd worker && python worker.py";
}
```

### CI/CD Environment

```nix
{
  enterTest = ''
    ruff check .
    ruff format --check .
    mypy .
    pytest --cov
  '';

  git-hooks.hooks = {
    ruff.enable = true;
    ruff-format.enable = true;
    mypy.enable = true;
  };
}
```

## Tips

1. **Search packages**: Use `devenv search <name>` to find available packages
2. **Service data**: Services store data in `.devenv/state/<service>/`
3. **Process logs**: Available in `.devenv/processes/`
4. **Environment info**: Run `devenv info` to see configuration details
5. **Update devenv**: `nix profile upgrade devenv`

## See Also

- **Official Options Reference**: https://github.com/cachix/devenv/blob/main/docs/src/reference/options.md
- **Language-specific configs**: See [language-configs.md](./language-configs.md)
- **Service configurations**: See [services-guide.md](./services-guide.md)
- **Process management**: See [processes-tasks.md](./processes-tasks.md)
- **Migration from nix-shell**: See [migration-guide.md](./migration-guide.md)
