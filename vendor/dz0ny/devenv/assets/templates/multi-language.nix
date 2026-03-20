# Multi-Language Development Environment Template
#
# Example configuration for projects using multiple programming languages:
# - Python (backend API)
# - JavaScript/Node (frontend)
# - Go (microservices)
# - Shared PostgreSQL and Redis
#
# Copy to your project root as devenv.nix and customize.

{ pkgs, ... }:

{
  # Shared development tools
  packages = with pkgs; [
    git
    gh
    jq
    curl
    gnumake

    # Linters and formatters
    ruff          # Python
    prettier      # JavaScript/TypeScript
    nodePackages.eslint

    # Database tools
    postgresql_17
  ];

  # Language configurations
  languages.python = {
    enable = true;
    version = "3.13";
    directory = "./python-api";  # Where pyproject.toml lives
    uv = {
      enable = true;
      sync.enable = true;  # Auto-sync on shell entry
    };
  };

  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_22;
    npm.enable = true;
  };

  languages.go = {
    enable = true;
    package = pkgs.go_1_22;
  };

  # Shared services
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_17;
    initialDatabases = [
      { name = "api_dev"; }
      { name = "microservice_dev"; }
    ];
  };

  services.redis = {
    enable = true;
    port = 6379;
  };

  # Environment variables
  env = {
    # Python backend
    PYTHON_API_DATABASE_URL = "postgresql:///api_dev?host=$PGHOST";

    # Go microservice
    GO_SERVICE_DATABASE_URL = "postgresql:///microservice_dev?host=$PGHOST";

    # Shared
    REDIS_URL = "redis://127.0.0.1:6379";
  };

  # Development processes
  processes = {
    # Python API
    python-api = {
      exec = "cd python-api && uvicorn app:app --reload --port 8000";
      process-compose = {
        depends_on = {
          postgres.condition = "process_healthy";
          redis.condition = "process_healthy";
        };
        readiness_probe = {
          http_get = {
            host = "localhost";
            port = 8000;
            path = "/health";
          };
        };
      };
    };

    # JavaScript frontend
    frontend = {
      exec = "cd frontend && npm run dev";
      process-compose = {
        depends_on = {
          python-api.condition = "process_healthy";
        };
      };
    };

    # Go microservice
    go-service = {
      exec = "cd go-service && go run main.go";
      process-compose = {
        depends_on = {
          postgres.condition = "process_healthy";
          redis.condition = "process_healthy";
        };
        readiness_probe = {
          http_get = {
            host = "localhost";
            port = 9000;
            path = "/health";
          };
        };
      };
    };
  };

  # Scripts
  scripts = {
    # Setup all components
    setup = {
      exec = ''
        echo "Setting up Python API..."
        cd python-api && uv sync --dev && cd ..

        echo "Setting up JavaScript frontend..."
        cd frontend && npm install && cd ..

        echo "Setting up Go service..."
        cd go-service && go mod download && cd ..

        echo "Setup complete!"
      '';
      description = "Install dependencies for all components";
    };

    # Test all components
    test = {
      exec = ''
        echo "Testing Python API..."
        cd python-api && pytest && cd ..

        echo "Testing JavaScript frontend..."
        cd frontend && npm test && cd ..

        echo "Testing Go service..."
        cd go-service && go test ./... && cd ..
      '';
      description = "Run all tests";
    };

    # Build all components
    build = {
      exec = ''
        echo "Building Python API..."
        cd python-api && python -m build && cd ..

        echo "Building JavaScript frontend..."
        cd frontend && npm run build && cd ..

        echo "Building Go service..."
        cd go-service && go build -o bin/service && cd ..

        echo "Build complete!"
      '';
      description = "Build all components";
    };

    # Database migrations
    migrate = {
      exec = ''
        echo "Running Python API migrations..."
        cd python-api && alembic upgrade head && cd ..

        echo "Running Go service migrations..."
        cd go-service && ./migrate.sh && cd ..
      '';
      description = "Run database migrations";
    };

    # Format code in all languages
    format = {
      exec = ''
        echo "Formatting Python..."
        cd python-api && ruff format . && cd ..

        echo "Formatting JavaScript..."
        cd frontend && prettier --write . && cd ..

        echo "Formatting Go..."
        cd go-service && go fmt ./... && cd ..
      '';
      description = "Format code in all languages";
    };
  };

  # Shell initialization
  enterShell = ''
    # Setup Node environment
    cd frontend && npm install &>/dev/null && cd ..

    # Setup Go environment
    cd go-service && go mod download &>/dev/null && cd ..

    echo ""
    echo "================================================"
    echo "  Multi-Language Development Environment"
    echo "================================================"
    echo ""
    echo "Languages:"
    echo "  Python:     $(python --version)"
    echo "  Node.js:    $(node --version)"
    echo "  Go:         $(go version | cut -d' ' -f3)"
    echo ""
    echo "Services:"
    echo "  Python API: http://localhost:8000"
    echo "  Frontend:   http://localhost:3000"
    echo "  Go Service: http://localhost:9000"
    echo ""
    echo "Commands:"
    echo "  devenv up          - Start all services"
    echo "  devenv shell setup - Install all dependencies"
    echo "  devenv shell test  - Run all tests"
    echo "  devenv shell build - Build all components"
    echo ""
    echo "================================================"
  '';

  # Note: Python uv.sync.enable handles venv activation and Linux patchelf automatically
}
