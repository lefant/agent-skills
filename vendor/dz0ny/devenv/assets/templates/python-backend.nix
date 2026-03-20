# Python Backend Template with PostgreSQL and Redis
#
# Based on Hakuto's backend pattern:
# - Python 3.13 with uv package manager
# - PostgreSQL 17
# - Redis
# - Pre-commit hooks
# - Development processes
#
# Copy to your project root as devenv.nix and customize.

{ pkgs, ... }:

{
  # Development tools
  packages = with pkgs; [
    # Version control
    git
    gh

    # Utilities
    jq
    curl

    # Linters and formatters (or install in venv via uv)
    ruff

    # Database tools
    postgresql_17  # CLI tools (psql, pg_dump, etc.)
    pgweb          # Web-based database browser
  ];

  # Python with uv (automatic venv + patchelf)
  languages.python = {
    enable = true;
    version = "3.13";
    uv = {
      enable = true;
      sync.enable = true;  # Auto-sync on shell entry
    };
  };

  # PostgreSQL 17
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_17;
    initialDatabases = [
      { name = "myapp_dev"; }
      { name = "myapp_test"; }
    ];
    listen_addresses = "127.0.0.1";
  };

  # Redis
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
      exec = "uvicorn app:app --reload --host 0.0.0.0 --port 8000";
      process-compose = {
        depends_on = {
          postgres.condition = "process_healthy";
          redis.condition = "process_healthy";
        };
        readiness_probe = {
          http_get = {
            host = "localhost";
            port = 8000;
            path = "/health";  # Adjust to your health check endpoint
          };
          initial_delay_seconds = 3;
          period_seconds = 10;
        };
      };
    };

    # Background worker (optional, uncomment if using Celery/RQ)
    # worker = {
    #   exec = "celery -A app.celery worker --loglevel=info";
    #   process-compose = {
    #     depends_on = {
    #       redis.condition = "process_healthy";
    #     };
    #   };
    # };
  };

  # Scripts for common tasks
  scripts = {
    # Database setup
    devdb = {
      exec = ''
        # Wait for postgres
        until pg_isready; do
          echo "Waiting for PostgreSQL..."
          sleep 1
        done

        echo "Setting up development database..."
        # Add your database initialization here
        # Example: python scripts/init_db.py
      '';
      description = "Initialize development database";
    };

    # Run tests
    test = {
      exec = "pytest";
      description = "Run tests";
    };

    # Run tests with coverage
    test-coverage = {
      exec = "pytest --cov --cov-report=html";
      description = "Run tests with coverage report";
    };

    # Database migrations (adjust for your migration tool)
    migrate = {
      exec = "alembic upgrade head";  # Or: python manage.py migrate
      description = "Run database migrations";
    };
  };

  # Shell initialization
  enterShell = ''
    echo "Python backend environment ready!"
    echo ""
    echo "Available commands:"
    echo "  devenv up          - Start backend + services"
    echo "  devenv shell test  - Run tests"
    echo "  devenv shell devdb - Setup database"
    echo ""
    echo "Database: $DATABASE_URL"
    echo "Redis:    $REDIS_URL"
  '';

  # Note: uv.sync.enable handles venv activation and Linux patchelf automatically
}
