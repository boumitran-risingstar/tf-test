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
    ];
    # Enable previews
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["npm" "start" "--prefix" "src"];
          manager = "web";
        };
      };
    };
    # Workspace lifecycle hooks
    workspace = {
      # Runs when a workspace is first created
      onCreate = {
        npm-install = "npm install --prefix src";
        # Configure Docker to use gcloud for authentication with Artifact Registry
        configure-docker = "gcloud auth configure-docker us-central1-docker.pkg.dev --quiet";
        # Open editors for the following files by default, if they exist:
        default.openFiles = [ "terraform/main.tf" "src/index.js" ];
      };
      # Runs when the workspace is (re)started
      onStart = {
        start-server = "npm start --prefix src";
      };
    };
  };
}
# Trigger reload