# Troubleshooting Guide

## Common Migration Issues

### "devenv: command not found"

**Problem:** devenv not installed or not in PATH.

**Solution:**
```bash
# Install devenv
nix profile install nixpkgs#devenv

# Verify installation
devenv version

# If still not found, check PATH
echo $PATH | grep -o "[^:]*nix[^:]*"
```

### Shell Activation Fails

**Symptom:** `devenv shell` exits with errors or warnings.

**Common causes:**

**1. Syntax errors in devenv.nix:**
```bash
# Check for syntax errors
nix-instantiate --parse devenv.nix

# Look for detailed error
devenv shell --impure -vvv
```

**2. Missing inputs in devenv.yaml:**
```yaml
# Ensure inputs are defined
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixos-unstable
```

**3. Locked inputs out of sync:**
```bash
# Update devenv.lock
devenv update
```

### PostgreSQL initialScript Syntax Errors

**Problem:** `error: syntax error, unexpected ID` in PostgreSQL initialScript.

**Symptom:**
```
error: at /path/to/devenv.nix:83:13:
   82|       CREATE USER hakuto_dev WITH PASSWORD '';
   83|       ALTER DATABASE hakuto_dev OWNER TO hakuto_dev;
      |             ^
error: syntax error, unexpected ID, expecting '.' or '='
```

**Cause:** In Nix multi-line strings (`''...''`), the sequence `''` ends the string. SQL's empty password `''` conflicts with Nix syntax.

**Solution:** Escape single quotes with `''''`:
```nix
services.postgres.initialScript = ''
  -- Wrong: This breaks!
  CREATE USER myuser WITH PASSWORD '';

  -- Correct: Use escaped quotes
  CREATE USER myuser WITH PASSWORD '''';
'';
```

### Python uv.sync in Monorepo

**Problem:** `No pyproject.toml found` when using `languages.python.uv.sync.enable = true`.

**Symptom:**
```
--- devenv:python:uv failed with error: Task exited with status: exit status: 1
--- devenv:python:uv stderr:
No pyproject.toml found. Make sure you have a pyproject.toml file in your project.
```

**Cause:** Automatic uv sync runs from project root, but `pyproject.toml` is in a subdirectory (e.g., `backend/`).

**Solution:** Disable automatic sync and run manually in enterShell:
```nix
{
  languages.python = {
    enable = true;
    version = "3.13";
    # Don't enable automatic sync for monorepo
    # uv.sync.enable = true;  # Remove this!
  };

  # Add uv to packages
  packages = [ pkgs.uv ];

  enterShell = ''
    # Manually sync from correct directory
    echo "Setting up Python environment..."
    (cd backend && uv sync --dev)
  '';
}
```

### nixpkgs-python Input Required

**Problem:** `To use 'languages.python.version', run the following command: $ devenv inputs add nixpkgs-python...`

**Cause:** devenv's `languages.python.version` option requires the `nixpkgs-python` input.

**Solution:** Add nixpkgs-python to devenv.yaml:
```yaml
# devenv.yaml
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixos-25.11

  nixpkgs-python:
    url: github:cachix/nixpkgs-python
    inputs:
      nixpkgs:
        follows: nixpkgs
```

### process-compose Environment Format Error

**Problem:** `yaml: unmarshal errors: line X: cannot unmarshal !!map into types.Environment`

**Symptom:**
```
Failed to parse process-compose.yaml error="yaml: unmarshal errors:
  line 52: cannot unmarshal !!map into types.Environment"
```

**Cause:** `environment` in process-compose expects a list of strings, not a Nix attribute set.

**Solution:** Use list format for environment variables:
```nix
processes.myprocess = {
  exec = "...";
  process-compose = {
    # Wrong: Nix attribute set
    environment = {
      NODE_NO_WARNINGS = "1";
      DEBUG = "true";
    };

    # Correct: List of strings
    environment = [
      "NODE_NO_WARNINGS=1"
      "DEBUG=true"
    ];
  };
};
```

### OpenAPI Generation Must Run Before Frontend Build

**Problem:** Frontend build fails with "MODULE NOT FOUND - Api.Data" errors.

**Cause:** Frontend code imports generated API modules that don't exist yet.

**Solution:** Generate OpenAPI client in `enterTest` (runs before `enterShell`):
```nix
{
  # enterTest runs BEFORE enterShell - perfect for code generation
  enterTest = ''
    echo "Generating OpenAPI client..."

    TMP_OUT=$(mktemp -d)

    openapi-generator-cli generate \
      --input-spec backend/src/myapp/openapi.yaml \
      --generator-name elm \
      --output "$TMP_OUT"

    elm-format --yes "$TMP_OUT/src/"

    cp -r "$TMP_OUT/src/"* frontend/src/

    rm -rf "$TMP_OUT"

    echo "✓ OpenAPI client generated"
  '';

  enterShell = ''
    # Now frontend build can proceed - API modules exist
    if [[ ! -d frontend/dist ]]; then
      echo "Building frontend..."
      (cd frontend && make dist)
    fi
  '';
}
```

**Order of execution:**
1. `enterTest` - Code generation, build-time tasks
2. `enterShell` - Environment setup, interactive tasks

### "Package Not Found" Errors

**Problem:** `error: attribute 'packageName' missing`

**Solutions:**

**1. Check package name:**
```bash
# Search for package
nix search nixpkgs packageName

# Use correct attribute
packages = [ pkgs.correctPackageName ];
```

**2. Check nixpkgs channel:**
```yaml
# devenv.yaml - use unstable for newer packages
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixos-unstable
```

**3. Package from different channel:**
```nix
# devenv.yaml
inputs:
  nixpkgs-unstable:
    url: github:NixOS/nixpkgs/nixos-unstable

# devenv.nix
{ pkgs, inputs, ... }:
{
  packages = [
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.newPackage
  ];
}
```

## Platform-Specific Issues

### Linux: patchelf for Python Wheels

**Problem:** Python packages with C extensions fail to import on NixOS.

**Symptom:**
```
ImportError: libstdc++.so.6: cannot open shared object file
```

**Modern Solution (Recommended):**
Use `directory` + `uv.sync.enable` - devenv handles patchelf automatically:

```nix
{ pkgs, ... }:

{
  languages.python = {
    enable = true;
    version = "3.13";
    directory = "./";  # Or "./backend" for subdirectory projects
    uv = {
      enable = true;
      sync.enable = true;  # Auto-handles patchelf on Linux
    };
  };
}
```

**Manual Solution (if needed):**
Only required if NOT using `directory` + `uv.sync.enable`:

```nix
{ pkgs, ... }:

{
  languages.python = {
    enable = true;
    uv.enable = true;
  };

  enterShell = ''
    uv sync --dev
    source .venv/bin/activate
  '';

  packages = [ pkgs.patchelf ];

  enterTest = pkgs.lib.optionalString pkgs.stdenv.isLinux ''
    # Patch .so files in venv
    if [ -d .venv ] && [ ! -f .venv/.patched ]; then
      find .venv -name "*.so" -type f | while read -r so_file; do
        patchelf --set-rpath "${pkgs.stdenv.cc.cc.lib}/lib:$(patchelf --print-rpath "$so_file" 2>/dev/null || true)" "$so_file" 2>/dev/null || true
      done
      touch .venv/.patched
    fi
  '';
}
```

**Affected packages:**
- numpy, scipy, pandas
- psycopg2, psycopg3
- cryptography, lxml
- opencv-python, pillow

**Not needed on:**
- macOS
- Non-NixOS Linux (Ubuntu, Fedora, etc.)

### macOS: Framework Linking Issues

**Problem:** Some packages fail to build or link on macOS.

**Symptom:**
```
ld: framework not found CoreFoundation
```

**Solution:**
```nix
{ pkgs, ... }:

{
  # Add macOS frameworks
  packages = pkgs.lib.optionals pkgs.stdenv.isDarwin [
    pkgs.darwin.apple_sdk.frameworks.CoreFoundation
    pkgs.darwin.apple_sdk.frameworks.Security
    pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
  ];
}
```

### Linux: Locale Issues

**Problem:** Locale warnings or unicode errors.

**Symptom:**
```
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings
```

**Solution:**
```nix
env = {
  LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  LC_ALL = "en_US.UTF-8";
};
```

### WSL (Windows Subsystem for Linux)

**Problem:** Services fail to start in WSL.

**Common issues:**
- systemd not available
- Port binding issues
- File permissions

**Solutions:**

**1. Use WSL2 (not WSL1):**
```bash
# Check WSL version
wsl -l -v

# Upgrade to WSL2 if needed
wsl --set-version Ubuntu 2
```

**2. Enable systemd in WSL2:**
```bash
# /etc/wsl.conf
[boot]
systemd=true
```

**3. Avoid localhost conflicts:**
```nix
# Use specific IPs instead of localhost
services.postgres.listen_addresses = "127.0.0.1";
```

## Service Issues

### PostgreSQL Won't Start

**Problem:** `devenv up` fails or postgres process exits.

**Debugging:**
```bash
# Check logs
cat .devenv/state/postgres/postgresql.log

# Check data directory
ls -la .devenv/state/postgres/

# Check port
lsof -i :5432  # Or netstat -an | grep 5432
```

**Common causes:**

**1. Port already in use:**
```nix
# Change port
services.postgres.port = 5433;

# Update connection strings
env.DATABASE_URL = "postgresql:///mydb?host=$PGHOST&port=5433";
```

**2. Corrupted data directory:**
```bash
# Reset postgres
devenv processes stop postgres
rm -rf .devenv/state/postgres
devenv up postgres  # Will reinitialize
```

**3. Permission issues:**
```bash
# Ensure state directory is writable
chmod -R u+w .devenv/state/
```

**4. Version mismatch:**
```bash
# If data directory from different postgres version
rm -rf .devenv/state/postgres
# Then restart postgres
```

### Redis Connection Refused

**Problem:** `Error: connect ECONNREFUSED 127.0.0.1:6379`

**Debugging:**
```bash
# Check if redis is running
devenv processes | grep redis

# Try manual connection
redis-cli -p 6379 ping

# Check port
lsof -i :6379
```

**Solutions:**

**1. Redis not started:**
```bash
devenv up redis
```

**2. Wrong port:**
```nix
# Verify port in devenv.nix matches application
services.redis.port = 6379;
env.REDIS_URL = "redis://127.0.0.1:6379";
```

**3. Port conflict:**
```nix
# Change redis port
services.redis.port = 6380;
env.REDIS_URL = "redis://127.0.0.1:6380";
```

### Service Data Persistence

**Problem:** Database data lost after restart.

**Explanation:** devenv services use `.devenv/state/` for data.

**Ensure data persists:**
```bash
# Check .gitignore includes .devenv/
echo ".devenv/" >> .gitignore

# Data location
ls -la .devenv/state/postgres/
ls -la .devenv/state/redis/
```

**Intentionally reset:**
```bash
devenv processes stop
rm -rf .devenv/state/postgres
devenv up postgres  # Fresh database
```

## Language-Specific Issues

### Python: Module Not Found

**Problem:** `ModuleNotFoundError` for installed package.

**Common causes:**

**1. Virtual environment not activated:**
```nix
# Ensure venv activates in enterShell
enterShell = ''
  source .venv/bin/activate
'';
```

**2. PYTHONPATH pollution:**
```nix
# Clear PYTHONPATH from nixpkgs
enterShell = ''
  unset PYTHONPATH
  source .venv/bin/activate
'';
```

**3. Package not installed:**
```bash
# Verify package in venv
pip list | grep packagename

# If missing, sync dependencies
uv sync --dev
```

**4. Wrong Python version:**
```bash
# Check active Python
which python
python --version

# Should match devenv.nix version
```

### Python: uv sync Fails

**Problem:** `uv sync` errors with resolution or download failures.

**Solutions:**

**1. Network issues:**
```bash
# Clear uv cache
uv cache clean

# Retry
uv sync --dev
```

**2. Dependency conflicts:**
```bash
# Check pyproject.toml for conflicts
# Update dependencies
uv lock --upgrade-package problematic-package
```

**3. Platform-specific wheels:**
```bash
# Force rebuild
rm -rf .venv
uv sync --dev --reinstall
```

### Python: Playwright Browser Issues

**Problem:** Playwright can't find browsers or fails to run.

**Solution (Hakuto pattern):**
```nix
{ pkgs, ... }:

{
  packages = [ pkgs.playwright-driver ];

  env.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";

  enterShell = ''
    # Install Playwright (if not in pyproject.toml)
    uv pip install playwright

    # Browsers from Nix, no need to run: playwright install
  '';
}
```

**Alternative (download browsers):**
```bash
# Let Playwright download browsers to project
unset PLAYWRIGHT_BROWSERS_PATH
python -m playwright install
```

### JavaScript: npm install Fails

**Problem:** `EACCES` or permission errors during `npm install`.

**Causes:**
- npm trying to write to read-only Nix paths
- Global prefix pointing to Nix store

**Solutions:**

**1. Use local node_modules:**
```nix
languages.javascript = {
  enable = true;
  npm.enable = true;
};

# node_modules will be created in project directory
```

**2. Set npm prefix explicitly:**
```nix
enterShell = ''
  export npm_config_prefix="$PWD/.npm-global"
'';
```

**3. Clear npm cache:**
```bash
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

### Elm: Package Download Failures

**Problem:** Elm can't download packages or `elm make` fails.

**Solutions:**

**1. Clear elm-stuff:**
```bash
rm -rf elm-stuff/
elm make src/Main.elm  # Re-downloads packages
```

**2. Network/proxy issues:**
```bash
# Check internet connection
# Elm downloads from package.elm-lang.org
```

**3. Corrupted package cache:**
```bash
rm -rf ~/.elm
elm make src/Main.elm  # Rebuilds cache
```

## Performance Issues

### Slow Shell Activation

**Problem:** `devenv shell` takes a long time to activate.

**Causes:**

**1. Expensive enterShell operations:**
```nix
# Avoid heavy operations in enterShell
enterShell = ''
  # Bad: Run build on every shell entry
  npm run build  # Takes 30+ seconds

  # Good: Use a script instead
  echo "Run 'devenv shell build' to build frontend"
'';

scripts.build.exec = "npm run build";
```

**2. Nix evaluation overhead:**
```bash
# Profile evaluation
nix-instantiate --eval devenv.nix --show-trace

# Check for expensive imports or computations
```

**3. Large number of packages:**
```nix
# Minimize packages in devenv.nix
# Install dev tools in venv/npm instead
packages = [
  # Only essential tools that need Nix
];
```

### Slow Service Startup

**Problem:** `devenv up` takes a long time to start services.

**Causes:**

**1. Database initialization:**
```nix
# Reduce initial data seeding
services.postgres = {
  enable = true;
  initialScript = ''
    -- Keep initialization minimal
    CREATE DATABASE myapp;
  '';
};

# Move large data imports to a script
scripts.seed.exec = "python scripts/seed_large_data.py";
```

**2. Process dependencies:**
```bash
# Check which processes are waiting
devenv up -vv
```

**3. Health check delays:**
```nix
# Reduce health check delays
processes.backend = {
  exec = "uvicorn app:app --reload";
  process-compose = {
    readiness_probe = {
      http_get = {
        path = "/health";
        port = 8000;
      };
      initial_delay_seconds = 1;  # Reduce from default 5s
      period_seconds = 3;          # Check more frequently
    };
  };
};
```

### High Disk Usage

**Problem:** `.devenv/` directory grows very large.

**Causes:**

**1. Service data accumulation:**
```bash
# Check size
du -sh .devenv/state/*

# Clear old data
rm -rf .devenv/state/postgres  # Will reinitialize
rm -rf .devenv/state/redis
```

**2. Nix store:**
```bash
# Nix store is global, not in project
# Clean old generations
nix-collect-garbage -d
```

**3. Build artifacts:**
```bash
# Clean build outputs
rm -rf .devenv/state/process-compose/logs/
```

## Debugging Tips

### Verbose Mode

```bash
# Show detailed output
devenv shell -vvv

# Show Nix evaluation trace
nix-instantiate --eval devenv.nix --show-trace
```

### Check devenv Info

```bash
# Show configuration
devenv info

# Lists:
# - Enabled languages
# - Configured services
# - Defined processes
# - Available scripts
```

### Inspect Environment

```nix
scripts.debug-env.exec = ''
  echo "=== Environment Variables ==="
  env | grep -E "(DATABASE|REDIS|PYTHON|PATH)" | sort

  echo "=== Which Commands ==="
  which python
  which node
  which psql

  echo "=== Versions ==="
  python --version
  node --version
  psql --version
'';
```

Run with: `devenv shell debug-env`

### Process Logs

**View all logs:**
```bash
devenv up  # Foreground mode shows all logs
```

**View specific process:**
```bash
# In process-compose TUI (when running devenv up)
# - Use arrow keys to select process
# - Press 'l' to view logs
# - Press 'f' to follow logs
# - Press 'q' to go back
```

**Log files location:**
```bash
ls -la .devenv/state/process-compose/logs/
cat .devenv/state/process-compose/logs/backend.log
```

### Network Debugging

**Check listening ports:**
```bash
# macOS
lsof -i -P | grep LISTEN

# Linux
netstat -tulpn | grep LISTEN
# or
ss -tulpn | grep LISTEN
```

**Check specific port:**
```bash
lsof -i :5432  # PostgreSQL
lsof -i :6379  # Redis
lsof -i :8000  # Backend
```

**Test service connectivity:**
```bash
# PostgreSQL
psql -h localhost -p 5432 -U $USER -l

# Redis
redis-cli -h 127.0.0.1 -p 6379 ping

# HTTP service
curl http://localhost:8000/health
```

## Getting Help

### devenv Documentation

- Official docs: https://devenv.sh
- GitHub issues: https://github.com/cachix/devenv/issues
- Discourse: https://discourse.nixos.org (tag: devenv)

### Debugging Steps

1. **Check syntax**: `nix-instantiate --parse devenv.nix`
2. **Verbose mode**: `devenv shell -vvv`
3. **Check logs**: View service/process logs in `.devenv/state/`
4. **Inspect environment**: Create debug script to print env vars
5. **Isolate issue**: Simplify devenv.nix to minimal config, add back incrementally
6. **Search**: Check GitHub issues for similar problems
7. **Ask**: Post on Discourse with:
   - devenv version
   - Platform (macOS/Linux/WSL)
   - Minimal devenv.nix reproducing issue
   - Error messages

### Common Gotchas

1. **Forgetting direnv:** devenv works best with `use devenv` in `.envrc`
2. **PYTHONPATH pollution:** Always `unset PYTHONPATH` for Python projects
3. **Service dependencies:** Use `depends_on` with `process_healthy` condition
4. **Health checks:** Define health checks for critical services
5. **Platform differences:** Test on all platforms team uses (macOS, Linux, WSL)
6. **Data persistence:** Remember `.devenv/state/` for service data
7. **Nix cache:** First build may be slow, subsequent builds use cache
8. **Version pinning:** Pin service versions to avoid surprises

## Known Limitations

### devenv Limitations

1. **Single postgres instance:** Can't run multiple postgres versions simultaneously
2. **No Windows native support:** Use WSL on Windows
3. **Service configuration:** Not all service options exposed (use extraConfig if needed)
4. **Process limits:** Very large number of processes (50+) may be slow

### Workarounds

**Multiple databases (same postgres):**
```nix
services.postgres = {
  enable = true;
  initialDatabases = [
    { name = "db1"; }
    { name = "db2"; }
  ];
};
```

**Advanced service config:**
```nix
services.postgres = {
  enable = true;
  settings = {
    # Custom postgres.conf settings
  };
};
```

**Complex process orchestration:**
Consider keeping process-compose.yml for very complex setups, and use devenv for environment + services only.

## Further Reading

- [Migration Guide](./migration-guide.md) - Converting from nix-shell
- [Language Configurations](./language-configs.md) - Python, Elm, JavaScript setup
- [Services Guide](./services-guide.md) - PostgreSQL, Redis configuration
- [Processes and Tasks](./processes-tasks.md) - Process management
