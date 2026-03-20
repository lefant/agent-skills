# Services Guide

## Overview

devenv manages services as long-running processes with dedicated data directories, automatic initialization, and health checks. Services are defined declaratively and managed through `devenv up`.

**Key benefits:**
- Automatic start/stop lifecycle
- Project-local data directories (no global state)
- Health checks and restart policies
- Process dependencies
- Isolated from system services

## PostgreSQL

### Basic Setup

```nix
{ pkgs, ... }:

{
  services.postgres = {
    enable = true;
  };
}
```

Start the service:
```bash
devenv up postgres
```

Connect:
```bash
psql  # Connects to default 'postgres' database
```

### Version Selection

```nix
services.postgres = {
  enable = true;
  package = pkgs.postgresql_17;  # or postgresql_16, postgresql_15, etc.
};
```

**Hakuto uses PostgreSQL 17:**
```nix
services.postgres = {
  enable = true;
  package = pkgs.postgresql_17;
};
```

### Database Initialization

**Create databases on first start:**
```nix
services.postgres = {
  enable = true;
  initialDatabases = [
    { name = "myapp_dev"; }
    { name = "myapp_test"; }
  ];
};
```

**Run SQL script on initialization:**
```nix
services.postgres = {
  enable = true;
  initialScript = ''
    CREATE DATABASE myapp_dev;
    CREATE USER myapp_user WITH PASSWORD 'dev_password';
    GRANT ALL PRIVILEGES ON DATABASE myapp_dev TO myapp_user;
  '';
};
```

**Load SQL from file:**
```nix
services.postgres = {
  enable = true;
  initialScript = builtins.readFile ./init.sql;
};
```

### Connection Configuration

**Unix socket (default):**
```nix
services.postgres.enable = true;

# Connect via socket (no host/port needed)
env.DATABASE_URL = "postgresql:///myapp_dev?host=$PGHOST";
```

devenv sets `$PGHOST` to the Unix socket directory (typically `.devenv/state/postgres`).

**TCP/IP connection:**
```nix
services.postgres = {
  enable = true;
  listen_addresses = "127.0.0.1";  # Listen on localhost
  port = 5432;
};

env.DATABASE_URL = "postgresql://localhost:5432/myapp_dev";
```

**Hakuto pattern** (socket-based):
```nix
services.postgres = {
  enable = true;
  package = pkgs.postgresql_17;
  initialDatabases = [{ name = "hakuto_dev"; }];
  listen_addresses = "127.0.0.1";
};

env.DATABASE_URL = "postgresql:///hakuto_dev?host=$PGHOST";
```

### Extensions

```nix
services.postgres = {
  enable = true;
  extensions = extensions: [
    extensions.postgis
    extensions.pg_cron
    extensions.timescaledb
  ];

  settings = {
    shared_preload_libraries = "pg_cron,timescaledb";
  };
};
```

**Enable extension in database:**
```nix
services.postgres = {
  enable = true;
  extensions = extensions: [ extensions.postgis ];

  initialScript = ''
    CREATE EXTENSION IF NOT EXISTS postgis;
  '';
};
```

### PostgreSQL Configuration

**Custom settings:**
```nix
services.postgres = {
  enable = true;

  settings = {
    max_connections = 100;
    shared_buffers = "256MB";
    work_mem = "16MB";
    log_statement = "all";  # Log all queries (dev only!)
  };
};
```

### Multiple PostgreSQL Versions

**Run different versions simultaneously:**
```nix
services.postgres = {
  enable = true;
  package = pkgs.postgresql_17;
  port = 5432;
};

# Note: devenv doesn't support multiple postgres instances directly
# Use separate devenv.nix files or manual process definitions
```

### Data Directory

PostgreSQL data is stored in `.devenv/state/postgres/`.

**Reset database:**
```bash
devenv processes stop postgres
rm -rf .devenv/state/postgres
devenv up postgres  # Will reinitialize
```

**Backup/restore:**
```bash
# Backup
pg_dump myapp_dev > backup.sql

# Restore
psql myapp_dev < backup.sql
```

### Migrating from process-compose

**Before (process-compose.yml):**
```yaml
processes:
  postgresql:
    command: ".pgsql/run.sh"
    environment:
      - "PGDATA=./.pgsql/data"
      - "PGHOST=./.pgsql"
    availability:
      restart: "always"
```

**After (devenv.nix):**
```nix
services.postgres = {
  enable = true;
  # Data directory and socket automatically managed in .devenv/state/postgres
};
```

## Redis

### Basic Setup

```nix
services.redis = {
  enable = true;
};
```

Start:
```bash
devenv up redis
```

Connect:
```bash
redis-cli ping  # Should return PONG
```

### Port Configuration

```nix
services.redis = {
  enable = true;
  port = 6379;  # Default, can be changed
};

env.REDIS_URL = "redis://127.0.0.1:6379";
```

### Bind Address

```nix
services.redis = {
  enable = true;
  bind = "127.0.0.1";  # Only localhost (default)
};
```

### Persistence

**RDB snapshots (default):**
```nix
services.redis = {
  enable = true;
  # Saves automatically with default RDB policy
};
```

**AOF (append-only file):**
```nix
services.redis = {
  enable = true;
  extraConfig = ''
    appendonly yes
    appendfilename "appendonly.aof"
  '';
};
```

**No persistence (dev mode):**
```nix
services.redis = {
  enable = true;
  extraConfig = ''
    save ""
  '';
};
```

### Data Directory

Redis data stored in `.devenv/state/redis/`.

**Clear Redis data:**
```bash
devenv processes stop redis
rm -rf .devenv/state/redis
devenv up redis
```

**Or use FLUSHALL:**
```bash
redis-cli FLUSHALL
```

### Hakuto Pattern

```nix
services.redis = {
  enable = true;
  port = 6379;
};

env.REDIS_URL = "redis://127.0.0.1:6379";
```

### Migrating from process-compose

**Before:**
```yaml
redis:
  command: "redis-server --port 6379 --bind 127.0.0.1"
  availability:
    restart: "always"
```

**After:**
```nix
services.redis = {
  enable = true;
  port = 6379;
  bind = "127.0.0.1";
};
```

## MySQL

### Basic Setup

```nix
services.mysql = {
  enable = true;
};
```

Connect:
```bash
mysql  # Connects to default database
```

### Version Selection

```nix
services.mysql = {
  enable = true;
  package = pkgs.mysql80;  # or mysql84, mariadb, etc.
};
```

### Database Initialization

```nix
services.mysql = {
  enable = true;
  initialDatabases = [
    { name = "myapp_dev"; }
    { name = "myapp_test"; }
  ];
};
```

### Configuration

```nix
services.mysql = {
  enable = true;

  settings = {
    mysqld = {
      max_connections = 200;
      innodb_buffer_pool_size = "1G";
      log_bin_trust_function_creators = 1;
    };
  };
};
```

### Data Directory

MySQL data in `.devenv/state/mysql/`.

**Reset:**
```bash
devenv processes stop mysql
rm -rf .devenv/state/mysql
devenv up mysql
```

## MongoDB

### Basic Setup

```nix
services.mongodb = {
  enable = true;
};
```

### Configuration

```nix
services.mongodb = {
  enable = true;
  additionalArgs = [
    "--bind_ip"
    "127.0.0.1"
    "--port"
    "27017"
  ];
};

env.MONGODB_URL = "mongodb://127.0.0.1:27017/myapp_dev";
```

## Elasticsearch

### Basic Setup

```nix
services.elasticsearch = {
  enable = true;
};
```

### Configuration

```nix
services.elasticsearch = {
  enable = true;
  port = 9200;
  cluster_name = "devenv-cluster";
};

env.ELASTICSEARCH_URL = "http://127.0.0.1:9200";
```

## RabbitMQ

### Basic Setup

```nix
services.rabbitmq = {
  enable = true;
};
```

### Configuration

```nix
services.rabbitmq = {
  enable = true;
  port = 5672;
  managementPlugin.enable = true;  # Web UI on port 15672
};

env.RABBITMQ_URL = "amqp://guest:guest@localhost:5672/";
```

## Nginx

### Basic Setup

```nix
services.nginx = {
  enable = true;
  httpConfig = ''
    server {
      listen 8080;
      location / {
        proxy_pass http://localhost:3000;
      }
    }
  '';
};
```

### Reverse Proxy for Dev Servers

```nix
services.nginx = {
  enable = true;
  httpConfig = ''
    server {
      listen 8080;

      # Frontend
      location / {
        proxy_pass http://localhost:1234;  # elm-land server
        proxy_set_header Host $host;
      }

      # API
      location /api {
        proxy_pass http://localhost:8000;  # Backend API
        proxy_set_header Host $host;
      }
    }
  '';
};
```

## Caddy

Modern web server alternative to nginx:

```nix
services.caddy = {
  enable = true;
  config = ''
    localhost:8080 {
      reverse_proxy localhost:3000
    }
  '';
};
```

## Service Management

### Starting Services

**Start all services:**
```bash
devenv up
```

**Start specific service:**
```bash
devenv up postgres redis
```

**Start in background:**
```bash
devenv up -d
```

### Stopping Services

```bash
# Stop all
devenv processes stop

# Stop specific service
devenv processes stop postgres
```

### Service Logs

**View logs:**
```bash
devenv up  # Shows logs in foreground

# Or with process-compose UI
devenv up  # Press 'l' to view logs for selected process
```

**Tail logs for specific service:**
```bash
tail -f .devenv/state/postgres/postgresql.log
```

### Health Checks

Services have automatic health checks. Dependent processes wait for services to be healthy.

**Example:** Backend waits for postgres to be ready:
```nix
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

### Restart Policies

**Always restart (default for services):**
Services automatically restart on failure.

**Manual restart:**
```bash
devenv processes restart postgres
```

## Common Patterns

### Multiple Databases (PostgreSQL)

```nix
services.postgres = {
  enable = true;
  initialDatabases = [
    { name = "app_dev"; }
    { name = "app_test"; }
    { name = "analytics_dev"; }
  ];
};

env.DATABASE_URL = "postgresql:///app_dev?host=$PGHOST";
env.TEST_DATABASE_URL = "postgresql:///app_test?host=$PGHOST";
env.ANALYTICS_DATABASE_URL = "postgresql:///analytics_dev?host=$PGHOST";
```

### Redis for Multiple Purposes

**Single Redis instance with multiple databases:**
```nix
services.redis.enable = true;

env.CACHE_REDIS_URL = "redis://127.0.0.1:6379/0";
env.QUEUE_REDIS_URL = "redis://127.0.0.1:6379/1";
env.SESSION_REDIS_URL = "redis://127.0.0.1:6379/2";
```

### Service + Background Worker

```nix
services.postgres.enable = true;
services.redis.enable = true;

processes = {
  api = {
    exec = "uvicorn app:app --reload";
    process-compose.depends_on = {
      postgres.condition = "process_healthy";
      redis.condition = "process_healthy";
    };
  };

  worker = {
    exec = "celery -A app.celery worker --loglevel=info";
    process-compose.depends_on = {
      redis.condition = "process_healthy";
    };
  };
};
```

### Database Initialization Script

**Setup script that runs before app starts:**
```nix
services.postgres = {
  enable = true;
  initialDatabases = [{ name = "myapp_dev"; }];
};

scripts.setup-db.exec = ''
  # Wait for postgres to be ready
  until pg_isready; do sleep 1; done

  # Run migrations
  cd backend && alembic upgrade head
'';

processes.backend = {
  exec = "setup-db && uvicorn app:app --reload";
  process-compose.depends_on.postgres.condition = "process_healthy";
};
```

### Service Configuration per Environment

```nix
{ pkgs, config, ... }:

let
  isDev = true;  # Or read from environment variable
in {
  services.postgres = {
    enable = true;
    settings = {
      log_statement = if isDev then "all" else "none";
      max_connections = if isDev then 50 else 200;
    };
  };

  services.redis = {
    enable = true;
    extraConfig = if isDev then ''
      save ""  # No persistence in dev
    '' else ''
      save 900 1
      save 300 10
      save 60 10000
    '';
  };
}
```

## Troubleshooting Services

### PostgreSQL Won't Start

**Check logs:**
```bash
cat .devenv/state/postgres/postgresql.log
```

**Common issues:**
- Port already in use: Change `services.postgres.port`
- Corrupted data directory: `rm -rf .devenv/state/postgres`
- Permission issues: Check that `.devenv/state/` is writable

### Redis Connection Refused

**Check if Redis is running:**
```bash
devenv processes | grep redis
```

**Check port:**
```bash
redis-cli -p 6379 ping
```

**Common issues:**
- Wrong port in connection string
- Redis not started: `devenv up redis`

### Service Data Persistence

**Services use project-local data directories.**

Location: `.devenv/state/<service>/`

**Gitignore these directories:**
```bash
echo ".devenv/" >> .gitignore
```

**Share data across team:** Don't commit service data. Use initialization scripts instead:
```nix
services.postgres = {
  enable = true;
  initialScript = builtins.readFile ./init.sql;
};
```

### Service Port Conflicts

**Error:** "Address already in use"

**Solutions:**
```nix
# Change port
services.postgres.port = 5433;
services.redis.port = 6380;

# Or stop conflicting service
sudo systemctl stop postgresql
sudo systemctl stop redis
```

### Slow Service Startup

**PostgreSQL initialization takes time on first run.**

**Speed up:**
- Use `initialDatabases` instead of `initialScript` when possible
- Minimize initial data seeding
- Consider separating large data imports into a script task

## Best Practices

### 1. Use Service Features Over Manual Setup

**Good:**
```nix
services.postgres = {
  enable = true;
  initialDatabases = [{ name = "myapp"; }];
};
```

**Avoid:**
```nix
packages = [ pkgs.postgresql_17 ];
enterShell = ''
  # Manual postgres setup
  initdb -D .pgdata
  pg_ctl -D .pgdata start
'';
```

### 2. Pin Service Versions

```nix
services.postgres.package = pkgs.postgresql_17;  # Explicit version
services.mysql.package = pkgs.mysql80;
```

### 3. Document Service Dependencies

```nix
# Backend requires PostgreSQL 17+ for generated columns
services.postgres.package = pkgs.postgresql_17;

# Frontend needs Redis for session storage
services.redis.enable = true;
```

### 4. Isolate Test Databases

```nix
services.postgres = {
  enable = true;
  initialDatabases = [
    { name = "app_dev"; }
    { name = "app_test"; }
  ];
};

env.DATABASE_URL = "postgresql:///app_dev?host=$PGHOST";
env.TEST_DATABASE_URL = "postgresql:///app_test?host=$PGHOST";
```

Tests should use `TEST_DATABASE_URL` to avoid polluting dev database.

### 5. Health Checks Are Critical

Always use health checks for process dependencies:
```nix
processes.backend = {
  exec = "uvicorn app:app --reload";
  process-compose.depends_on.postgres.condition = "process_healthy";
};
```

Without this, backend may start before postgres is ready, causing connection errors.

## Further Reading

- [Processes and Tasks](./processes-tasks.md) - Using services with processes
- [Troubleshooting](./troubleshooting.md) - Service-specific issues
- [Migration Guide](./migration-guide.md) - Converting process-compose services
