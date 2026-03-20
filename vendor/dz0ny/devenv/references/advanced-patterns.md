# Advanced devenv Patterns

Real-world patterns and best practices from production devenv configurations.

## Process Management Patterns

### One-Time Initialization Process

Run migrations or setup tasks once, then exit:

```nix
processes.db-init = {
  exec = ''
    cd backend
    echo "Running migrations..."
    uv run alembic upgrade head
    uv run python -m app.scripts.seed_data
    echo "✓ Database initialized"
    exit 0  # Exit successfully
  '';
  process-compose = {
    depends_on = {
      postgres.condition = "process_healthy";
      redis.condition = "process_healthy";
    };
    # Critical: Don't restart after completion
    availability.restart = "no";
  };
};
```

**Key points:**
- Process exits with `exit 0` after completion
- `availability.restart = "no"` prevents restart loop
- Other processes can depend on it with `process_completed_successfully`

### Process Dependency Chain

Build complex startup sequences:

```nix
processes = {
  # Step 1: Services start and become healthy
  postgres = { /* ... */ };
  redis = { /* ... */ };

  # Step 2: One-time initialization
  db-init = {
    process-compose.depends_on = {
      postgres.condition = "process_healthy";
      redis.condition = "process_healthy";
    };
    # ... exits after completion ...
  };

  # Step 3: Application servers start
  backend = {
    process-compose.depends_on = {
      postgres.condition = "process_healthy";
      redis.condition = "process_healthy";
      db-init.condition = "process_completed_successfully";
    };
  };

  frontend = {
    process-compose.depends_on = {
      backend.condition = "process_healthy";
    };
  };
};
```

**Condition types:**
- `process_healthy` - Readiness probe passing
- `process_completed` - Process exited (any code)
- `process_completed_successfully` - Process exited with 0
- `process_started` - Process started (no health check)

### Custom Health Checks

#### Override Default Service Health Check

```nix
processes.postgres.process-compose = {
  readiness_probe = {
    exec.command = lib.mkForce ''
      ${pkgs.postgresql_17}/bin/psql -h 127.0.0.1 -p 5432 -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='myapp_user'" | grep -q 1
    '';
    initial_delay_seconds = lib.mkForce 2;
    period_seconds = lib.mkForce 2;
    timeout_seconds = lib.mkForce 5;
    success_threshold = lib.mkForce 1;
    failure_threshold = lib.mkForce 30;
  };
};
```

**Why override:**
- Default checks connectivity, not schema readiness
- Custom check verifies `initialScript` completed
- Prevents race conditions with dependent processes

**Use `lib.mkForce` to override devenv defaults.**

#### HTTP Health Check

```nix
processes.api = {
  exec = "uvicorn app:app --host 0.0.0.0 --port 8000";
  process-compose = {
    readiness_probe = {
      http_get = {
        host = "127.0.0.1";
        port = 8000;
        path = "/health";
      };
      initial_delay_seconds = 2;
      period_seconds = 10;
      timeout_seconds = 5;
      success_threshold = 1;
      failure_threshold = 3;
    };
  };
};
```

#### TCP Health Check

```nix
processes.myservice = {
  exec = "my-tcp-service";
  process-compose = {
    readiness_probe = {
      tcp_socket = {
        host = "127.0.0.1";
        port = 9000;
      };
      initial_delay_seconds = 1;
      period_seconds = 5;
    };
  };
};
```

#### Command-Based Health Check

```nix
processes.rabbitmq = {
  exec = "rabbitmq-server";
  process-compose = {
    readiness_probe = {
      exec.command = "rabbitmqctl status";
      initial_delay_seconds = 5;
      period_seconds = 10;
    };
  };
};
```

### Inline Build Dependencies

Check and build dependencies in process exec:

```nix
processes.backend = {
  exec = ''
    cd backend
    # Build frontend if not exists
    test -L src/app/static/dist || make -C ../frontend dist
    # Start backend
    uvicorn app:app --reload
  '';
};
```

**Pattern:**
```bash
test <condition> || <build-command> && <main-command>
```

### Restart Policies

```nix
processes = {
  # Always restart on failure (default)
  backend = {
    process-compose.availability.restart = "on_failure";
  };

  # Never restart (one-time tasks)
  db-init = {
    process-compose.availability.restart = "no";
  };

  # Always restart (even on success)
  worker = {
    process-compose.availability.restart = "always";
  };
};
```

### Process-Specific Environment

```nix
processes.frontend = {
  exec = "npm run dev";
  process-compose = {
    environment = [
      "NODE_NO_WARNINGS=1"
      "DEBUG=app:*"
    ];
  };
};
```

### TTY Control for Colored Output

```nix
processes.tailwind = {
  exec = "tailwindcss -i src/input.css -o dist/output.css --watch";
  process-compose = {
    is_tty = true;  # Enable TTY for colored output
  };
};
```

**When to use:**
- Tools that detect TTY for color output (Tailwind, Vite, etc.)
- Pretty-printed logs with ANSI codes

## Database Patterns

### Advanced PostgreSQL Setup

#### Multiple Databases with Roles

```nix
services.postgres = {
  enable = true;
  package = pkgs.postgresql_17;
  listen_addresses = "127.0.0.1";
  port = 5432;

  # Create multiple databases
  initialDatabases = [
    { name = "myapp_dev"; }
    { name = "myapp_test"; }
  ];

  # Complex initialization
  initialScript = ''
    -- Development database
    DO $do$
    BEGIN
       IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'myapp_dev') THEN
          CREATE ROLE myapp_dev LOGIN;
       END IF;
    END $do$;

    ALTER DATABASE myapp_dev OWNER TO myapp_dev;
    GRANT ALL PRIVILEGES ON DATABASE myapp_dev TO myapp_dev;

    \c myapp_dev
    CREATE EXTENSION IF NOT EXISTS pgcrypto;
    CREATE EXTENSION IF NOT EXISTS hstore;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

    -- Test database
    \c postgres
    DO $do$
    BEGIN
       IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'myapp_test') THEN
          CREATE ROLE myapp_test LOGIN;
       END IF;
    END $do$;

    ALTER DATABASE myapp_test OWNER TO myapp_test;
    GRANT ALL PRIVILEGES ON DATABASE myapp_test TO myapp_test;

    \c myapp_test
    CREATE EXTENSION IF NOT EXISTS pgcrypto;
  '';

  # Custom settings
  settings = {
    log_statement = "all";
    log_duration = true;
    log_connections = false;
    log_disconnections = false;
    max_connections = 100;
    shared_buffers = "256MB";
    timezone = "UTC";
  };
};
```

#### Why Use initialScript with DO Blocks

**Problem:** Multiple `devenv up` runs fail if roles exist.

**Solution:** Use `DO` blocks with `IF NOT EXISTS`:

```sql
DO $do$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'myuser') THEN
      CREATE ROLE myuser LOGIN;
   END IF;
END $do$;
```

**Idempotent:** Safe to run multiple times.

### Connection String Patterns

```nix
env = {
  # Unix socket (faster, local only)
  DATABASE_URL = "postgresql:///myapp_dev?host=$PGHOST";

  # TCP (required for network access)
  DATABASE_URL_TCP = "postgresql://myapp_dev@127.0.0.1:5432/myapp_dev";

  # Test database
  TEST_DATABASE_URL = "postgresql:///myapp_test?host=$PGHOST";
};
```

**Note:** `$PGHOST` is set by devenv to `.devenv/state/postgres` socket directory.

### Database Tools

```nix
packages = [
  pkgs.pgweb  # Web-based PostgreSQL browser
  pkgs.postgresql_17  # For psql CLI
];

scripts.db-console.exec = ''
  psql -h 127.0.0.1 -p 5432 -d myapp_dev
'';

scripts.db-web.exec = ''
  pgweb --host 127.0.0.1 --port 5432 --db myapp_dev
'';
```

## Python Environment Patterns

### UV with Virtual Environment

```nix
languages.python = {
  enable = true;
  version = "3.13";
  # Note: Using uv for package management
};

packages = [ pkgs.uv ];

enterShell = ''
  # Setup Python environment
  echo "Setting up Python environment..."
  (cd backend && uv sync --dev)

  # Critical: Unset PYTHONPATH to avoid Nix pollution
  unset PYTHONPATH

  # Export virtual environment for type checkers and tools
  export VIRTUAL_ENV="$PROJECT_ROOT/backend/.venv"
  export PATH="$VIRTUAL_ENV/bin:$PATH"
'';
```

**Why unset PYTHONPATH:**
- Nix may set PYTHONPATH pointing to Nix store
- Causes import conflicts with venv packages
- Type checkers get confused

**Why export VIRTUAL_ENV:**
- Tools like mypy, pylint need to find venv
- Some tools don't auto-detect .venv

### Python Tools from Nix (for Speed)

```nix
packages = [
  # Install via Nix for caching
  pkgs.ruff
  pkgs.ty
  python313Packages.coverage
];

git-hooks.hooks = {
  ruff = {
    entry = "bash -c 'cd backend && ${pkgs.ruff}/bin/ruff check --fix .'";
    # Use Nix package, not venv version
  };
};
```

**Why:**
- Nix packages cached across projects
- Git hooks run faster (no venv activation)
- Consistent versions across team

## Frontend Build Patterns

### Conditional Build on Shell Entry

```nix
enterShell = ''
  # Only build if dist doesn't exist
  if [[ ! -d "$PROJECT_ROOT/frontend/dist" ]]; then
    echo "Building frontend..."
    (cd "$PROJECT_ROOT/frontend" && make dist)
  fi
'';
```

**Avoids:** Rebuilding frontend on every `devenv shell`.

### OpenAPI Client Generation

```nix
enterShell = ''
  # Generate API client (required for frontend)
  echo "Generating OpenAPI client..."
  (cd "$PROJECT_ROOT/frontend" && make openapi-gen)
'';
```

**Pattern:** Generate before frontend build.

### Symlink for ESLint Dependencies

```nix
enterShell = ''
  # ESLint needs node_modules for plugins
  ln -sfn ${pkgs.nodePackages.eslint}/lib/node_modules/eslint/node_modules "$PROJECT_ROOT/frontend/node_modules"
'';
```

**Why:**
- ESLint from Nix, but expects node_modules
- Symlink Nix store location

## Script Patterns

### Clean Database State Script

```nix
scripts.devup.exec = ''
  echo "Cleaning database state..."
  rm -rf .devenv/state/postgres
  echo "Starting services..."
  devenv up
'';
```

**Use case:** Fresh start with clean database.

### Conditional Demo Skip

```nix
scripts.demo.exec = ''
  cd backend && make demo ${"\${1:+skip-to-step=$1}"}
'';
```

**Usage:**
```bash
demo           # Run all steps
demo 2         # Skip to step 2
```

### Test Coverage Script

```nix
scripts.test-cov.exec = ''
  cd backend
  uv run coverage run -m pytest
  uv run coverage report
  uv run coverage html
'';
```

## Environment Variable Patterns

### Playwright Browser Path

```nix
env = {
  PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
};
```

**Why:**
- Playwright needs browser binaries
- Point to Nix-managed browsers

### Database URLs

```nix
env = {
  # Use $PGHOST set by devenv
  DATABASE_URL = "postgresql:///myapp_dev?host=$PGHOST";
  REDIS_URL = "redis://127.0.0.1:6379";
};
```

### API Keys (via dotenv)

```nix
dotenv.enable = true;

# .env file (gitignored)
OPENAI_API_KEY=sk-...
STRIPE_API_KEY=sk_test_...
```

## enterTest vs enterShell

### CI (enterTest)

```nix
enterTest = ''
  # Run in CI/testing
  cd backend && make unit
'';
```

### Development (enterShell)

```nix
enterShell = ''
  # Setup for development
  uv sync --dev
  npm install

  echo "✨ Development environment ready!"
'';
```

**Difference:**
- `enterTest` - Build/test time (CI)
- `enterShell` - Runtime (developer shell)

## User-Friendly Help Message

```nix
enterShell = ''
  # ... setup ...

  echo ""
  echo "✨ MyApp development environment ready!"
  echo ""
  echo "Quick start:"
  echo "  devup                  Clean database and start all services"
  echo "  devenv up              Start services without cleaning"
  echo ""
  echo "What 'devup' starts:"
  echo "  1. PostgreSQL 17       (127.0.0.1:5432)"
  echo "  2. Redis               (127.0.0.1:6379)"
  echo "  3. Database Init       (Migrations + seed data)"
  echo "  4. Backend API         (http://localhost:8000)"
  echo "  5. Frontend            (http://localhost:3000)"
  echo ""
  echo "Other commands:"
  echo "  test-cov               Run tests with coverage"
  echo "  demo                   Generate demo data"
  echo ""
'';
```

## Git Hooks with Working Directory

For monorepos or tools that need specific working directory:

```nix
git-hooks.hooks = {
  ruff = {
    enable = true;
    entry = "bash -c 'cd backend && ${pkgs.ruff}/bin/ruff check --fix .'";
    files = "^backend/";
    pass_filenames = false;
  };

  elm-review = {
    enable = true;
    entry = "bash -c 'cd frontend && ${pkgs.elmPackages.elm-review}/bin/elm-review'";
    files = "^frontend/.*\\.elm";
    pass_filenames = false;
  };
};
```

## Common Gotchas

### 1. Health Check Timing

**Problem:** Backend starts before database ready.

**Solution:**
```nix
processes.postgres.process-compose.readiness_probe = {
  initial_delay_seconds = lib.mkForce 2;
  failure_threshold = lib.mkForce 30;  # Wait up to 60 seconds
};
```

### 2. One-Time Process Restarts

**Problem:** db-init keeps restarting.

**Solution:**
```nix
processes.db-init.process-compose.availability.restart = "no";
```

### 3. PYTHONPATH Pollution

**Problem:** Import errors from Nix Python packages.

**Solution:**
```nix
enterShell = ''
  unset PYTHONPATH
'';
```

### 4. Missing Frontend Build

**Problem:** Backend 404s on static files.

**Solution:**
```nix
processes.backend.exec = ''
  test -L src/static/dist || make -C ../frontend dist
  uvicorn app:app
'';
```

## Best Practices Summary

1. **Health Checks**
   - Always use readiness probes for services
   - Verify schema readiness, not just connectivity
   - Adjust timing for slow-starting services

2. **Process Dependencies**
   - Use explicit `depends_on` with conditions
   - Chain: services → initialization → application

3. **One-Time Tasks**
   - Exit with `exit 0`
   - Set `availability.restart = "no"`
   - Use `process_completed_successfully` condition

4. **Python Environments**
   - Always `unset PYTHONPATH`
   - Export `VIRTUAL_ENV` for tools
   - Use Nix packages for speed (ruff, etc.)

5. **Database Setup**
   - Use `DO` blocks for idempotent initialScript
   - Create roles with `IF NOT EXISTS`
   - Set up multiple databases if needed

6. **User Experience**
   - Add helpful enterShell messages
   - Create convenience scripts (devup, etc.)
   - Document what each process does

7. **Conditional Builds**
   - Only build when needed
   - Check for existence before building
   - Generate API clients before builds

8. **Git Hooks**
   - Use `bash -c 'cd ...'` for working directory
   - Set `pass_filenames = false` for whole-project tools
   - Use Nix packages for speed
