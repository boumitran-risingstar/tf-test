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
    FIREBASE_SERVICE_ACCOUNT_KEY = "ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsCiAgInByb2plY3RfaWQiOiAidGYtdGVzdC00NzYwMDIiLAogICJwcml2YXRlX2tleV9pZCI6ICI0NjVkNjIyY2Y4NGMzYjkxNjc0MDNkNWQ1MWM0ODg5MzdmMDY5OWJkIiwKICAicHJpdmF0ZV9rZXkiOiAiLS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tXG5NSUlFdmdJQkFEQU5CZ2txaGtpRzl3MEJBUUVGQUFTQ0JLZ3dnZ1NrQWdFQUFvSUJBUUR1ckdWY200cXFEaVpDXG40d1VFeW5taU55T1hyM3F5NmlGQnpiZWpQb2Z3L1NWUktPRDBhYVA1bFRtYlo4OTltVWdMcGR3MzVpcnIzSmZ2XG55VzVLMHRaYWxVL3B2am5UY1hUUkMwT2VwRzFUOWlnZ0hMZVF5K1p6bTBBSTNkRVliMUh3OThPdXdyYWUvL3JOXG5xOXN5aEJrbXMyZlBXNHczUGJDSG5LaCtsT2piMWpnL3VIeFAzMzl6SzZINnA1dGpySmRVdFJiSlB0U1NuNTYxXG5SaVh5QlpncnRiakU2NjRQUDhaaGtDMlVZVXBicFV2Sy9UbUZVTnI5UVdvaEhmUm8zaUcxbU9ZMVU0c3F3d2NyXG54NUxxUjU5OEQ3b2o4REZWR1Zhb3hrYXVERWdRbHhyY0svcm9menY0Zk9mN3BUUnVmYjV0YnljVkJBdTl5NGJJXG5PdlRXMjlNckFnTUJBQUVDZ2dFQWEyckVmYzcxTS84RlFsSTVKb1JZQk9WckMvQXF1VTQ5WklmSkQ5dnJRODh5XG4xZG1ma1BEZ24wb0ZjTWRpYjRVbWt6TjFMdVZVeU8xeHBqWlNnTE51VEx0cGlXb1hUVzRCSkxvOGx6QXFra0MxXG5vMm81Ulo0M0hDMnh2cXZTV1B4MDlRNFZrRmhLNTdtT2I3VmFoRnhHazQvbjl6K2RGaG1hRXhhekVMRkZNZmJUXG50b2wvamlUd081NHEwUG0yZjdHR2VMd1c1dVUxTFVsamN0bEg1STRVTkZWalBLM2V4Nk9Vd3pENi9JVnhnUUpFXG4rakh5SE9oM0taUmo4SjdkbXZKK2JLRG5UbWxBR1hEbzdTaEYyRzNmS3NDRlYxTTNzNEhkcncxbWNtUG9HSDFkXG5mbXQ2Vks4MnNCa2w0cGZNek9TRktzOG15OEtUQzNrVU9pbU8wdTBlSFFLQmdRRDdqYWFDNHZoT3lBc0Rla1I5XG4xZTh0bTF5WHg0ZndlRHlTbzd1TUpzVXV2UUdnMGxGZjQ0M3c4a1pXaTliSk1VbXZySVlFRnJmbGhBajBZOGtnXG5Hcy9PMEp0b1BFckNLTkZIL2NEUWEwek5mUTA3RjVaOVZ5ZWxnMlRwWEt6cUp5NTczNUlLM3RVZkFsbmtjcUsrXG55RTZneVM2QmZUVjdJN2tOaWE4REVSSjRMUUtCZ1FEeTVIWFltbnBrVmZaMjQxT1VhYnZRaHljZmIxREhUMEI3XG44bVRQSEx6RU50ZkFkYmhJc3NSdkxuL3cxMW9OWE1sWG0vMlZTWkVPUjA0MHFZT09nTnJmeEZsUXNMRWpKUXNWXG5NZi95VEw4YUF1OTg0bFJBbE4wRlJVK0twdEFQRWVwT29JWGh5UEp1R2ZoOFJVMEZHbWE3YnIzdmtscGowUGpRXG4za3VSKzlkM3R3S0JnUURKZkdzTDJWcUVWNnlpcTNOaXkxR1pXU0N3SGN6ZnFwN3g0WjJlSTR1NjVQOEIzcFA1XG5WeDNoQ1YyWGdzaVdQQmxHVWN6Q1I2UWlmVUJpNSs0My9lSEhTTVhCbHRGV2RUVTBFYWM0Q1VucUthaklWUnRmXG41OGhFeFZxMXBGcUg3cnhIMGdwN0ZJTG1KSTcxOFhBem1lT0kyN3VaVWozZEZQN3JQZ1hsVWU1V1BRS0JnRGRiXG4vTVFPaVdDKyt2cWoyMVBUT1h4UW9Za1huT2lnVm9rcGVQSi9rVUtEWVc4N0pYSmtWRU1tN1FBZWhTYlFoQTlVXG52Vm8rTnpKeTdBOHlwNHBlTWdTWVF1Y1NMbjFkSHdhSXE5WTB5Y1dLNzd5ZDlTZjNCZDBDckJ0azQ3emJqM1MyXG5QMjF6bUZXaDA3RzNOZE80N2J0QWhVZktLcEhmZWlaWTFBNkV3TnBIQW9HQkFMc05ubG5KaGJhd0ZUUmRwZGFyXG5SQy9CR0pWd25Pci9zTSsxT3dGb0d1b3kyR1AzRFIrbnd3QVNsY0tGZUNSN2YwVlhETFFyVXlEZ1BHdXlDTGgzXG53aXpNNXBwTDE5T2J0M2hsdkFqTGVSeWk5aXFmTjF3cnFyQlZ2eDJxS0l3TGRzT3lvcFA3MldEK0RPOGVrK2pQXG5nQ1ZWVE1UWkRvTXQraXF2NGZ1WnRZZ1Jcbi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS1cbiIsCiAgImNsaWVudF9lbWFpbCI6ICJhdXRoLXVpLXNhQHRmLXRlc3QtNDc2MDAyLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwKICAiY2xpZW50X2lkIjogIjExMzM2NjkzMzczNTA2MjA5NTA4MSIsCiAgImF1dGhfdXJpIjogImh0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbS9vL29hdXRoMi9hdXRoIiwKICAidG9rZW5fdXJpIjogImh0dHBzOi8vb2F1dGgyLmdvb2dsZWFwaXMuY29tL3Rva2VuIiwKICAiYXV0aF9wcm92aWRlcl94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL29hdXRoMi92MS9jZXJ0cyIsCiAgImNsaWVudF94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3JvYm90L3YxL21ldGFkYXRhL3g1MDkvYXV0aC11aS1zYSU0MHRmLXRlc3QtNDc2MDAyLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwKICAidW5pdmVyc2VfZG9tYWluIjogImdvb2dsZWFwaXMuY29tIgp9Cg==";
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
