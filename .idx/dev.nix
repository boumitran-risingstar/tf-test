
# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, config, ... }:
let
  globalEnv = {
    GOOGLE_CLOUD_PROJECT = "tf-test-476002";
    NEXT_PUBLIC_APP_URL="https://mouthmetrics.32studio.org";
    # The FIREBASE_SERVICE_ACCOUNT_KEY is a base64 encoded secret.
    # It'''s used in the onStart hook to generate a credentials file.
    FIREBASE_SERVICE_ACCOUNT_KEY = "gcp:secret:projects/mouth-metrics-476603/secrets/firebase-service-account-key/versions/latest";
    FIREBASE_PROJECT_ID = "gcp:secret:projects/mouth-metrics-476603/secrets/firebase-project-id/versions/latest";
    NEXT_PUBLIC_FIREBASE_PROJECT_ID = "gcp:secret:projects/mouth-metrics-476603/secrets/firebase-project-id/versions/latest";
    # GOOGLE_APPLICATION_CREDENTIALS is the standard way for Google Cloud libraries to find credentials.
    GOOGLE_APPLICATION_CREDENTIALS = "/tmp/gcp-credentials.json";
  };
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
    pkgs.coreutils # Provides 'base64'
  ];

  # Workspace-wide environment variables.
  env = globalEnv;

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
          # Inherit global env vars and add preview-specific ones
          env = globalEnv // {
            NEXT_PUBLIC_USERS_API_URL = "http://localhost:8080";
          };
          manager = "web";
          cwd = "auth-ui";
        };
        users-api = {
          command = ["npm" "start"];
          manager = "web";
          cwd = "users-api";
          # Inherit global env vars and add preview-specific ones
          env = globalEnv // {
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
        # Create a credentials file from the base64 encoded secret, and then install dependencies.
        # This is done in a single script to ensure sequential execution.
        "setup-and-install" = ''
          gcloud secrets versions access latest --secret=firebase-service-account-key --project=mouth-metrics-476603 | base64 -d > /tmp/gcp-credentials.json && \
          npm install --prefix auth-ui && \
          npm install --prefix users-api
        '';
      };
    };
  };
}
