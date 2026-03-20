# Basic devenv Configuration Template
#
# Minimal starter for new devenv projects.
# Copy this file to your project root as devenv.nix and customize.

{ pkgs, ... }:

{
  # Add packages (tools, utilities, build dependencies)
  packages = with pkgs; [
    git
    jq
  ];

  # Configure languages (Python, JavaScript, Go, Rust, etc.)
  # Uncomment and configure as needed:

  # languages.python = {
  #   enable = true;
  #   version = "3.13";
  # };

  # languages.javascript = {
  #   enable = true;
  #   package = pkgs.nodejs_22;
  # };

  # Environment variables
  env = {
    # EXAMPLE_VAR = "value";
  };

  # Commands to run when entering the shell
  enterShell = ''
    echo "Welcome to your devenv environment!"
    echo "Available commands:"
    echo "  devenv up    - Start services and processes"
    echo "  devenv info  - Show configuration"
  '';

  # Services (PostgreSQL, Redis, MySQL, etc.)
  # Uncomment and configure as needed:

  # services.postgres.enable = true;
  # services.redis.enable = true;

  # Processes (dev servers, watchers, workers)
  # processes = {
  #   dev = {
  #     exec = "echo 'No dev server configured yet'";
  #   };
  # };

  # Scripts (one-time commands and tasks)
  # scripts = {
  #   test.exec = "echo 'No tests configured yet'";
  #   build.exec = "echo 'No build configured yet'";
  # };
}
