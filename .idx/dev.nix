# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, config, ... }:
let
  # Create a credentials file for the service account
  google-creds-file = "";
in
{
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.nodejs_20
    pkgs.google-cloud-sdk
    pkgs.terraform
    pkgs.docker
    pkgs.tflint
  ];
  # Sets environment variables in the workspace
  env = {
    GOOGLE_CLOUD_PROJECT = "tf-test-476002";
    NEXT_PUBLIC_APP_URL="https://mouthmetrics.32studio.org";
  };
  # Enable the Docker daemon
  services.docker.enable = true;
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "hashicorp.terraform"
      "google.cloud-code"
      "dbaeumer.vscode-eslint" # For linting TypeScript and JavaScript 
      "esbenp.prettier-vscode" # For code formatting
    ];
    # Enable previews
    previews = {
      enable = true ;
      previews = {
        web = {
          # Use the Next.js development server command
          command = ["npm" "run" "dev" "--" "--port" "$PORT"];
          env = {
            NEXT_PUBLIC_USERS_API_URL = "http://localhost:8080";
          };
          manager = "web";
          cwd = "auth-ui";
        };
        users-api = {
          command = ["npm" "start"];
          manager = "web";
          cwd = "users-api";
          env = {
            # Ensure the API listens on the correct port
            PORT = "8080";
          };
        };
      };
    };
    # Workspace lifecycle hooks
    workspace = {
      # Runs when a workspace is first created
      onCreate = {
        # Configure Docker to use gcloud for authentication with Artifact Registry
        configure-docker = "gcloud auth configure-docker us-central1-docker.pkg.dev --quiet";
      };
      # Runs every time the workspace is (re)started
      onStart = {
        install-auth-ui = "npm install --prefix auth-ui";
        install-users-api = "npm install --prefix users-api";
      };
    };
  };
}
