# Processes and Tasks

## Overview

devenv provides two mechanisms for running commands:

- **Processes**: Long-running services (dev servers, watchers, workers)
- **Scripts**: One-time commands and tasks (builds, tests, migrations)

Both replace the need for external tools like process-compose, Procfile, or Makefile in many cases.

## Processes

Processes are long-running commands managed by devenv's built-in process manager (process-compose).

### Basic Process Definition

```nix
{ pkgs, ... }:

{
  processes = {
    backend = {
      exec = "uvicorn app:app --reload";
    };

    frontend = {
      exec = "npm run dev";
    };
  };
}
```

Start processes:
```bash
devenv up  # Starts all processes
```

### Process Configuration

**Full configuration options:**
```nix
processes.myapp = {
  exec = "python app.py";              # Command to execute
  process-compose = {
    command = "python app.py";         # Alternative to exec
    working_dir = "./backend";         # Working directory

    environment = [                    # Environment variables
      "DEBUG=1"
      "PORT=8000"
    ];

    depends_on = {                     # Process dependencies
      postgres.condition = "process_healthy";
      redis.condition = "process_healthy";
    };

    availability = {
      restart = "on_failure";          # or "always", "no"
      max_restarts = 5;
    };

    readiness_probe = {
      http_get = {
        host = "localhost";
        port = 8000;
        path = "/health";
      };
      initial_delay_seconds = 2;
      period_seconds = 5;
    };
  };
};
```

### Working Directory

**Relative to project root:**
```nix
processes.backend = {
  exec = "cd backend && uvicorn app:app --reload";
};

# Or using working_dir
processes.backend = {
  process-compose = {
    command = "uvicorn app:app --reload";
    working_dir = "./backend";
  };
};
```

### Environment Variables

**Process-specific environment:**
```nix
processes.backend = {
  exec = "uvicorn app:app --reload";
  process-compose = {
    environment = [
      "DEBUG=1"
      "LOG_LEVEL=debug"
      "PORT=8000"
    ];
  };
};
```

**Using devenv env variables:**
```nix
env.DATABASE_URL = "postgresql:///mydb?host=$PGHOST";

processes.backend = {
  exec = "uvicorn app:app --reload";
  # DATABASE_URL automatically available
};
```

### Process Dependencies

**Wait for services before starting:**
```nix
services.postgres.enable = true;
services.redis.enable = true;

processes.backend = {
  exec = "uvicorn app:app --reload";
  process-compose = {
    depends_on = {
      postgres.condition = "process_healthy";
      redis.condition = "process_healthy";
    };
  };
};
```

**Process depends on another process:**
```nix
processes = {
  api = {
    exec = "node api.js";
    process-compose = {
      readiness_probe = {
        http_get = {
          host = "localhost";
          port = 3000;
          path = "/health";
        };
      };
    };
  };

  worker = {
    exec = "node worker.js";
    process-compose = {
      depends_on = {
        api.condition = "process_healthy";
      };
    };
  };
};
```

**Dependency conditions:**
- `process_healthy`: Wait for health check to pass
- `process_started`: Wait for process to start (don't wait for health)
- `process_completed`: Wait for process to complete (for init processes)

### Restart Policies

**Always restart (default for services):**
```nix
processes.backend = {
  exec = "uvicorn app:app --reload";
  process-compose = {
    availability = {
      restart = "always";
    };
  };
};
```

**Restart on failure only:**
```nix
processes.frontend = {
  exec = "elm-land server --watch";
  process-compose = {
    availability = {
      restart = "on_failure";
      max_restarts = 3;  # Give up after 3 restarts
    };
  };
};
```

**No restart:**
```nix
processes.init = {
  exec = "./scripts/init.sh";
  process-compose = {
    availability = {
      restart = "no";
    };
  };
};
```

### Health Checks

**HTTP health check:**
```nix
processes.backend = {
  exec = "uvicorn app:app --reload";
  process-compose = {
    readiness_probe = {
      http_get = {
        host = "localhost";
        port = 8000;
        path = "/api/health";
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

**Exec health check:**
```nix
processes.worker = {
  exec = "celery worker";
  process-compose = {
    readiness_probe = {
      exec = {
        command = "celery inspect ping";
      };
      period_seconds = 30;
    };
  };
};
```

## Migrating from process-compose.yml

### Basic Conversion

**Before (process-compose.yml):**
```yaml
version: "0.5"

processes:
  postgresql:
    command: ".pgsql/run.sh"
    environment:
      - "PGDATA=./.pgsql/data"
      - "PGHOST=./.pgsql"
    availability:
      restart: "always"

  redis:
    command: "redis-server --port 6379 --bind 127.0.0.1"
    availability:
      restart: "always"

  backend:
    command: "cd backend && uvicorn app:app --reload"
    depends_on:
      postgresql:
        condition: process_healthy
      redis:
        condition: process_healthy
```

**After (devenv.nix):**
```nix
{
  # Services replace manual database processes
  services.postgres.enable = true;
  services.redis = {
    enable = true;
    port = 6379;
  };

  # Application processes
  processes.backend = {
    exec = "cd backend && uvicorn app:app --reload";
    process-compose = {
      depends_on = {
        postgres.condition = "process_healthy";
        redis.condition = "process_healthy";
      };
    };
  };
}
```

### Hakuto Frontend Pattern

**Before (frontend/process-compose.yml):**
```yaml
version: "0.5"

processes:
  elm-land:
    command: "elm-land server --watch"
    environment:
      - "NODE_NO_WARNINGS=1"
    availability:
      restart: "on_failure"

  tailwind:
    command: "tailwindcss -i ./src/style.css -o ./static/style.css --watch"
    is_tty: true
    availability:
      restart: "on_failure"
```

**After (devenv.nix):**
```nix
processes = {
  frontend-dev = {
    exec = "cd frontend && elm-land server --watch";
    process-compose = {
      environment = [ "NODE_NO_WARNINGS=1" ];
      availability.restart = "on_failure";
    };
  };

  frontend-css = {
    exec = "cd frontend && tailwindcss -i ./src/style.css -o ./static/style.css --watch";
    process-compose = {
      availability.restart = "on_failure";
    };
  };
};
```

### Hakuto Backend Pattern

**Before (backend/process-compose.yml):**
```yaml
version: "0.5"

processes:
  postgresql:
    command: ".pgsql/run.sh"
    environment:
      - "PGDATA=./.pgsql/data"
      - "PGHOST=./.pgsql"
    availability:
      restart: "always"

  redis:
    command: "redis-server --port 6379 --bind 127.0.0.1"
    availability:
      restart: "always"
```

**After (devenv.nix):**
```nix
services.postgres = {
  enable = true;
  package = pkgs.postgresql_17;
};

services.redis = {
  enable = true;
  port = 6379;
};

# Backend process added separately
processes.backend = {
  exec = "cd backend && uvicorn hakuto.app:app --reload";
  process-compose = {
    depends_on = {
      postgres.condition = "process_healthy";
      redis.condition = "process_healthy";
    };
  };
};
```

## Scripts and Tasks

Scripts are named commands for one-time operations (builds, tests, migrations).

### Basic Scripts

```nix
scripts = {
  build.exec = ''
    echo "Building project..."
    npm run build
  '';

  test.exec = ''
    pytest tests/
  '';

  migrate.exec = ''
    alembic upgrade head
  '';
};
```

Run scripts:
```bash
devenv shell build
devenv shell test
devenv shell migrate
```

### Script with Description

```nix
scripts = {
  build = {
    exec = ''
      npm run build
    '';
    description = "Build the frontend for production";
  };

  test = {
    exec = ''
      pytest tests/ --cov
    '';
    description = "Run tests with coverage";
  };
};
```

List available scripts:
```bash
devenv info
```

### Complex Scripts

**Multi-step build script:**
```nix
scripts.build-all.exec = ''
  echo "Building API client..."
  openapi-generator-cli generate \
    --input-spec backend/src/hakuto/openapi.yaml \
    --generator-name elm \
    --output frontend/src/
  elm-format --yes frontend/src/

  echo "Building frontend..."
  cd frontend && elm-land build && cd ..

  echo "Building backend..."
  cd backend && python -m build && cd ..

  echo "Build complete!"
'';
```

**Database setup script:**
```nix
scripts.devdb.exec = ''
  # Wait for postgres
  until pg_isready; do
    echo "Waiting for PostgreSQL..."
    sleep 1
  done

  # Drop and recreate database
  dropdb --if-exists hakuto_dev
  createdb hakuto_dev

  # Run migrations
  cd backend && alembic upgrade head

  # Seed data
  python -m hakuto.scripts.seed

  echo "Database ready!"
'';
```

### Hakuto Script Examples

**OpenAPI client generation:**
```nix
scripts.generate-api-client.exec = ''
  openapi-generator-cli generate \
    --input-spec backend/src/hakuto/openapi.yaml \
    --enable-post-process-file \
    --generator-name elm \
    --config frontend/openapi-generator.yml \
    --output frontend/src/
  elm-format --yes frontend/src/
'';
```

**Test execution:**
```nix
scripts = {
  test.exec = ''
    cd backend && pytest
  '';

  test-unit.exec = ''
    cd backend && pytest -m "not integration"
  '';

  test-integration.exec = ''
    cd backend && pytest -m integration
  '';

  test-coverage.exec = ''
    cd backend && pytest --cov --cov-report=html
  '';
};
```

**Demo generation:**
```nix
scripts.demo.exec = ''
  cd backend && python -m playwright install
  cd backend && python -m hakuto.scripts.demo
'';
```

## One-Time Initialization Processes

For tasks that should run once when services are ready (database migrations, initial data seeding):

### Database Initialization Process

```nix
processes = {
  # One-time database setup
  db-init = {
    exec = ''
      cd backend
      echo "Initializing database..."

      # Drop existing tables (dev environment)
      CHECK_DB_MIGRATED=0 python -m myapp.scripts.drop_tables

      # Run migrations
      alembic -c etc/development.ini upgrade head

      # Seed initial data
      python -m myapp.scripts.populate

      echo "✓ Database initialized"

      # Exit successfully - don't restart
      exit 0
    '';
    process-compose = {
      # Wait for services to be healthy
      depends_on = {
        postgres.condition = "process_healthy";
        redis.condition = "process_healthy";
      };
      # Don't restart after successful completion
      availability.restart = "no";
    };
  };

  # Backend depends on db-init completing successfully
  backend = {
    exec = "cd backend && uvicorn app:app --reload";
    process-compose = {
      depends_on = {
        postgres.condition = "process_healthy";
        redis.condition = "process_healthy";
        db-init.condition = "process_completed_successfully";
      };
      availability.restart = "on_failure";
    };
  };
};
```

**Key patterns:**
- Use `exit 0` to mark successful completion
- Set `availability.restart = "no"` to prevent restarts
- Other processes depend on `condition = "process_completed_successfully"`
- Initialization runs automatically on `devenv up`

### Build-Time vs Runtime Tasks

**enterTest** - Runs before shell activation (build-time):
```nix
enterTest = ''
  # Code generation - must happen before enterShell
  echo "Generating code..."
  openapi-generator-cli generate ...
  protoc --go_out=. ...

  # Asset compilation
  sass src/styles.scss dist/styles.css
'';
```

**enterShell** - Runs when entering shell (runtime):
```nix
enterShell = ''
  # Environment setup
  echo "Syncing dependencies..."
  (cd backend && uv sync)

  # Conditional builds (only if needed)
  if [[ ! -d dist ]]; then
    make build
  fi

  echo "Ready!"
'';
```

**processes** - Long-running services:
```nix
processes = {
  # Starts with devenv up, restarts on failure
  backend = {
    exec = "uvicorn app:app --reload";
    process-compose.availability.restart = "on_failure";
  };
};
```

**scripts** - On-demand tasks:
```nix
scripts = {
  # Run manually: devenv shell build
  build.exec = ''
    make build
  '';

  # Run manually: devenv shell test
  test.exec = ''
    pytest
  '';
};
```

## Common Patterns

### Fullstack Development (Hakuto)

```nix
{ pkgs, ... }:

{
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_17;
    initialDatabases = [{ name = "hakuto_dev"; }];
  };

  services.redis = {
    enable = true;
    port = 6379;
  };

  processes = {
    backend = {
      exec = "cd backend && uvicorn hakuto.app:app --reload --host 0.0.0.0 --port 8000";
      process-compose = {
        depends_on = {
          postgres.condition = "process_healthy";
          redis.condition = "process_healthy";
        };
        readiness_probe = {
          http_get = {
            host = "localhost";
            port = 8000;
            path = "/api/health";
          };
          initial_delay_seconds = 3;
        };
      };
    };

    frontend-dev = {
      exec = "cd frontend && elm-land server --watch";
      process-compose = {
        environment = [ "NODE_NO_WARNINGS=1" ];
        depends_on.backend.condition = "process_healthy";
      };
    };

    frontend-css = {
      exec = "cd frontend && tailwindcss -i ./src/style.css -o ./static/style.css --watch";
    };
  };

  scripts = {
    generate-api.exec = ''
      openapi-generator-cli generate \
        --input-spec backend/src/hakuto/openapi.yaml \
        --generator-name elm \
        --output frontend/src/
      elm-format --yes frontend/src/
    '';

    devdb.exec = ''
      until pg_isready; do sleep 1; done
      cd backend && python -m hakuto.scripts.devdb
    '';

    test.exec = ''
      cd backend && pytest
    '';

    demo.exec = ''
      cd backend && python -m hakuto.scripts.demo
    '';
  };

  enterShell = ''
    # Generate API client on shell entry
    generate-api
  '';
}
```

### API + Worker + Scheduler

```nix
processes = {
  api = {
    exec = "uvicorn app:app --reload";
    process-compose = {
      depends_on = {
        postgres.condition = "process_healthy";
        redis.condition = "process_healthy";
      };
    };
  };

  worker = {
    exec = "celery -A app.celery worker --loglevel=info";
    process-compose = {
      depends_on = {
        redis.condition = "process_healthy";
      };
    };
  };

  beat = {
    exec = "celery -A app.celery beat --loglevel=info";
    process-compose = {
      depends_on = {
        redis.condition = "process_healthy";
      };
    };
  };
};
```

### Frontend with Multiple Watchers

```nix
processes = {
  vite = {
    exec = "vite dev";
  };

  tailwind = {
    exec = "tailwindcss -w -i src/input.css -o dist/output.css";
  };

  typescript = {
    exec = "tsc --watch --noEmit";
  };
};
```

### Init Process + App Process

```nix
processes = {
  init = {
    exec = ''
      # Database migration
      alembic upgrade head

      # Seed data
      python scripts/seed.py
    '';
    process-compose = {
      availability.restart = "no";  # Run once
      depends_on.postgres.condition = "process_healthy";
    };
  };

  app = {
    exec = "uvicorn app:app --reload";
    process-compose = {
      depends_on = {
        init.condition = "process_completed";
        postgres.condition = "process_healthy";
      };
    };
  };
};
```

## Process Management

### Starting Processes

**All processes:**
```bash
devenv up
```

**Specific processes:**
```bash
devenv up backend frontend-dev
```

**Background mode:**
```bash
devenv up -d
```

### Stopping Processes

```bash
devenv processes stop
devenv processes stop backend  # Stop specific process
```

### Restarting Processes

```bash
devenv processes restart backend
```

### Viewing Logs

**In foreground mode:**
```bash
devenv up  # Shows all logs
```

**process-compose TUI:**
- Press `l` to view logs for selected process
- Press `f` to follow logs
- Press `q` to go back

### Process Status

```bash
devenv info  # Shows configured processes and scripts
```

## Scripts vs Processes vs enterShell

**Use Scripts for:**
- One-time commands (builds, tests)
- Manual operations (database seeding, migrations)
- Tasks users run explicitly

**Use Processes for:**
- Dev servers (uvicorn, elm-land, vite)
- File watchers (tailwindcss --watch)
- Background workers (celery, queue processors)
- Long-running services

**Use enterShell for:**
- Environment setup (activate venvs, set paths)
- One-time initialization (generate code, create symlinks)
- Welcome messages

**Example:**
```nix
scripts.test.exec = "pytest";        # Run manually: devenv shell test

processes.backend.exec = "uvicorn app:app --reload";  # Runs with: devenv up

enterShell = ''
  echo "Welcome! Run 'devenv up' to start services"
  generate-api-client  # Auto-run on shell entry
'';
```

## Best Practices

### 1. Declare Dependencies Explicitly

```nix
# Good: Backend waits for database
processes.backend = {
  exec = "uvicorn app:app --reload";
  process-compose.depends_on.postgres.condition = "process_healthy";
};

# Bad: Backend may start before postgres is ready
processes.backend.exec = "sleep 5 && uvicorn app:app --reload";
```

### 2. Use Health Checks

```nix
processes.api = {
  exec = "node server.js";
  process-compose = {
    readiness_probe = {
      http_get = {
        host = "localhost";
        port = 3000;
        path = "/health";
      };
    };
  };
};
```

Without health checks, dependent processes may start too early.

### 3. Set Appropriate Restart Policies

```nix
# Dev server: restart on failure (code errors)
processes.backend = {
  exec = "uvicorn app:app --reload";
  process-compose.availability.restart = "on_failure";
};

# Init script: run once
processes.init = {
  exec = "./init.sh";
  process-compose.availability.restart = "no";
};
```

### 4. Organize Scripts by Purpose

```nix
scripts = {
  # Development
  dev.exec = "devenv up";

  # Testing
  test.exec = "pytest";
  test-watch.exec = "pytest-watch";

  # Database
  devdb.exec = "python scripts/devdb.py";
  migrate.exec = "alembic upgrade head";

  # Build
  build.exec = "npm run build";
  build-api-client.exec = "openapi-generator-cli ...";
};
```

### 5. Document Complex Scripts

```nix
scripts = {
  demo = {
    exec = ''
      # Install Playwright browsers
      python -m playwright install

      # Generate demo content via browser automation
      python -m hakuto.scripts.demo
    '';
    description = "Generate demo content using Playwright automation";
  };
};
```

## Troubleshooting

### Process Won't Start

**Check dependencies:**
- Ensure `depends_on` services are running
- Verify condition is `process_healthy` (not `process_started`)

**Check health checks:**
- Verify health check path/port is correct
- Check process logs for startup errors

### Process Keeps Restarting

**Common causes:**
- Application crashes on startup
- Wrong working directory
- Missing environment variables

**Debug:**
```bash
devenv up  # View logs in foreground
# Or check .devenv/state/process-compose/logs/
```

### Process Hangs on Startup

**Likely cause:** Waiting for dependency that never becomes healthy.

**Solutions:**
- Check dependency service logs
- Verify health check configuration
- Use `process_started` instead of `process_healthy` if health check isn't needed

### Script Fails

**Run with verbose output:**
```bash
devenv shell -vvv myscript
```

**Check environment:**
```nix
scripts.debug.exec = ''
  echo "PATH=$PATH"
  echo "DATABASE_URL=$DATABASE_URL"
  which python
  python --version
'';
```

## Further Reading

- [Services Guide](./services-guide.md) - Configuring PostgreSQL, Redis, etc.
- [Language Configurations](./language-configs.md) - Setting up Python, Node, etc.
- [Troubleshooting](./troubleshooting.md) - Common issues and solutions
