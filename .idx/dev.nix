# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
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
  env = {};
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
      enable = true;
      previews = {
        web = {
          # Use the Next.js development server command
          command = ["npm" "run" "dev" "--" "--port" "$PORT"];
          manager = "web";
          cwd = "auth-ui";
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
        npm-install = "npm install --prefix auth-ui";
      };
    };
  };
}
