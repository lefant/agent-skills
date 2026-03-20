# Fullstack Application Template
#
# Based on Hakuto's complete pattern:
# - Backend: Python 3.13 + uv + PostgreSQL 17 + Redis
# - Frontend: Elm + elm-land + Tailwind CSS
# - OpenAPI client generation
# - Process orchestration
# - Pre-commit hooks
#
# Copy to your project root as devenv.nix and customize.

{ pkgs, ... }:

{
  # Development tools
  packages = with pkgs; [
    # Project-wide tools
    git
    gh
    jq
    curl

    # Backend linters/formatters
    ruff

    # Frontend build tools
    elm-land
    tailwindcss
    nodePackages.prettier
    nodePackages.eslint

    # API code generation
    openapi-generator-cli

    # Database tools
    postgresql_17  # CLI tools
    pgweb          # Web-based DB browser
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

  # Services
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_17;
    initialDatabases = [
      { name = "myapp_dev"; }
      { name = "myapp_test"; }
    ];
    listen_addresses = "127.0.0.1";
  };

  services.redis = {
    enable = true;
    port = 6379;
  };

  # Environment variables
  env = {
    DATABASE_URL = "postgresql:///myapp_dev?host=$PGHOST";
    TEST_DATABASE_URL = "postgresql:///myapp_test?host=$PGHOST";
    REDIS_URL = "redis://127.0.0.1:6379";
  };

  # Pre-commit hooks
  pre-commit.hooks = {
    ruff.enable = true;
    ruff-format.enable = true;
  };

  # Development processes
  processes = {
    # Backend API server
    backend = {
      exec = "cd backend && uvicorn app:app --reload --host 0.0.0.0 --port 8000";
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

    # Frontend dev server (elm-land)
    frontend-dev = {
      exec = "cd frontend && elm-land server --watch";
      process-compose = {
        environment = [ "NODE_NO_WARNINGS=1" ];
        depends_on = {
          backend.condition = "process_healthy";
        };
      };
    };

    # Frontend CSS watcher (Tailwind)
    frontend-css = {
      exec = "cd frontend && tailwindcss -i ./src/style.css -o ./static/style.css --watch";
      process-compose = {
        availability.restart = "on_failure";
      };
    };
  };

  # Scripts for common tasks
  scripts = {
    # Generate API client from OpenAPI spec
    generate-api-client = {
      exec = ''
        echo "Generating Elm API client from OpenAPI spec..."
        openapi-generator-cli generate \
          --input-spec backend/src/app/openapi.yaml \
          --generator-name elm \
          --config frontend/openapi-generator.yml \
          --output frontend/src/

        # Format generated Elm code
        ${pkgs.elmPackages.elm-format}/bin/elm-format --yes frontend/src/

        echo "API client generated successfully!"
      '';
      description = "Generate Elm API client from OpenAPI spec";
    };

    # Database setup
    devdb = {
      exec = ''
        until pg_isready; do
          echo "Waiting for PostgreSQL..."
          sleep 1
        done

        echo "Setting up development database..."
        cd backend && python -m app.scripts.init_db
      '';
      description = "Initialize development database";
    };

    # Backend tests
    test-backend = {
      exec = "cd backend && pytest";
      description = "Run backend tests";
    };

    # Frontend tests
    test-frontend = {
      exec = "cd frontend && elm-test";
      description = "Run frontend tests";
    };

    # Full test suite
    test = {
      exec = ''
        echo "Running backend tests..."
        cd backend && pytest

        echo "Running frontend tests..."
        cd ../frontend && elm-test
      '';
      description = "Run all tests (backend + frontend)";
    };

    # Build frontend for production
    build-frontend = {
      exec = ''
        cd frontend
        elm-land build
        echo "Frontend built to frontend/dist/"
      '';
      description = "Build frontend for production";
    };

    # Type checking
    typecheck = {
      exec = ''
        echo "Checking Python types..."
        cd backend && mypy .

        echo "Checking Elm types..."
        cd ../frontend && elm make src/Main.elm --output=/dev/null
      '';
      description = "Run type checkers for backend and frontend";
    };
  };

  # Shell initialization
  enterShell = ''
    # Generate API client
    generate-api-client

    # Build frontend (initial build)
    cd frontend && make dist 2>/dev/null || true && cd ..

    # Create ESLint node_modules symlink
    ln -sfn ${pkgs.nodePackages.eslint}/lib/node_modules/eslint/node_modules frontend/node_modules 2>/dev/null || true

    echo ""
    echo "========================================="
    echo "  Fullstack Development Environment"
    echo "========================================="
    echo ""
    echo "Backend:  http://localhost:8000"
    echo "Frontend: http://localhost:1234"
    echo ""
    echo "Commands:"
    echo "  devenv up                      - Start all services"
    echo "  devenv shell test              - Run all tests"
    echo "  devenv shell generate-api-client - Regenerate API client"
    echo "  devenv shell devdb             - Reset database"
    echo ""
    echo "Database: $DATABASE_URL"
    echo "Redis:    $REDIS_URL"
    echo "========================================="
  '';

  # Note: Python uv.sync.enable handles venv activation and Linux patchelf automatically
}
