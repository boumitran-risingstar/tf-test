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
    FIREBASE_SERVICE_ACCOUNT_KEY = "ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsCiAgInByb2plY3RfaWQiOiAibW91dGgtbWV0cmljcy00NzY2MDMiLAogICJwcml2YXRlX2tleV9pZCI6ICIwMTU0NWM1Mzg0MzdkYTNkYjk2NmUwZmM2YzQ1ZGE2MTcyNTg5OWNlIiwKICAicHJpdmF0ZV9rZXkiOiAiLS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tXG5NSUlFdmdJQkFEQU5CZ2txaGtpRzl3MEJBUUVGQUFTQ0JLZ3dnZ1NrQWdFQUFvSUJBUUN0eld4dERzYTRRYUlyXG5YOFM4MW5oRFIwL2k1ZVk3R0ZaUEE4RzVuN3MvbUxDNkNIT2hRZWR2N05uWHd0MEhiSWY5K3RwZkJsZmhaakpwXG54VXFyYjlNc05wbzhhWlNYUkFISGpnMU1MRmlpaGk1c3dxeU1xZWVOWTJ5cHg5OGs4Z0xja0Z0WHFNNTltUDV1XG5zNkptdnFrd0ZOcU1hVUFoMHdiOU1qbGJSalRoeWFGMmx4U1RtUnpYaXBlTS9kZEdibjFleVJ0UFlVazJiMVhPXG5mL2JwZEZLeThiek5BZ1ZHb3R2aHdKNXNHSkVpbTNOMDUwOFArOThDUkttelQ1YnhGOWZsL2JOQUdicWRuZldyXG5uZjNCbWpxOGQzRVBXbGhxbXpKRWIvUzlSaStxejI5U095U3VTTllhYlZyWUNhNExFbVgrS3NiMDBJdy9rOHBBXG56cWR5VkF0SEFnTUJBQUVDZ2dFQU9LY2Q0VHl3VE81a0FMUnlha1dVcFFXUlJqby9QbU1UK3lTVDJNQjI1bWVNXG5yODlDZGIySVJjVVVTMDdqQW1EL3dTdXNVODQ3Qmlkc1ptcmZpSnRtWCtLYWl2ZTFia3RHTXppY0lBalNpWU9vXG5qVjQxcFpKYWZvMTZwYXNYa3pEcCt1QjVUYzBpSmZHaGVnOUc4Q3ZVOVczT3dYY3JadnNsSzVKYi9PTVpLTUdwXG5MM1NaUXJ6Ym43Y3Q2ZjI0Z0U4WUpwU2VnRzBZc2JKKzZkSE9NcnZRMmZhRjE4bXBLOWlDM3UwNjZ0bHBpdFhwXG5zUGkyUWRLdjFzdTNmOUNnb2EydFFnbTFHSWEyUDc3eWxpenJLcEVBZTN4OEkyazhRczlZc1RWN3Z2bEYyQzU5XG5NRzVWcExGRHQyNkExb0gzSmQrOGsrSjNXbk5McCtzMG92RjNIR1EwTVFLQmdRRG5JSXk3ZmZnVHNwRTM4Y1doXG5zRkp0cnE1Zi9hM1ZJWStnUDdvQnd5UG43MnVsdERsRzE3QXlHMmdNOUFNMEtHd1RmME5YSGhTbGFENkJEd29hXG4xeS9aYWprTDRlVW43Tk1wSEZFaVB1UnI2QjJlYnRBYlVzOXZGZGNGbGN1TmpvejE2cXYwK2FOWGZOYmRrZ2pXXG5xczJPR0Z6WkplRTk0T2VBUXdtcW9HZS9VUUtCZ1FEQWdacDcvUjE1cWVrbFpsMDlJVFBLRVNhSFVscFpDd0RKXG41V2Y4NVlmUTkvdkxyaUZDNS94NXBMSGNLd0hDWVRKZTFCWm95Y25xeVI1Mng4MGowNExCMnhTTmpXOWlvd1ZKXG5mOTJCOGZuZVNGS2M5YkRyY1NtWUdDSExLdjF4VFRvS0VOSlY3VlIvbUl2TmYyVXFrWGdTNm1BcGd2K3l6VXVnXG41cEx2OXB0ckZ3S0JnUUM2N2xPRWJOeVFxZExUeVlKTFJIMVdZbnA3L29OeXBvTXdXM3BJWkppTXhOSnVvYlhWXG5leXJ4UzhNNi9ydjhtbGpXNkE0QnpyMXFEa2JIUU8rdVI2NVdqSmY0NlVuYW9hc2pTOWkrOXRqdUFUeTdYK3FHXG52dEl3aVJ4d1V2ZmYxSlJqYk5xSTlzTEtScGpOZVlnV2Z1eGphWWJteGNGSHQ3Zmt2OU40b2VWbkVRS0JnUUN1XG41bEdNS3ZqWHErYldndjFkWjhnYzQ1NGt2azYxcmNpR3BuWG5FRWRvTlpaQWhMRlZqMTRVeXV5SmcwMXk1RW9XXG5YQTBNSWFIaFBkNyt2aU1FVk12dEF2WFdjZFRzUWY2d3U0cHQ0SUpMVVZ3MW5RZWpzY20vbE5WSE9JVFJwdjkvXG5XNjh1UUpWUDVESElmK0ZUWHAxQVdrOEtDQ24yc296dTMrNUtOTDBaK3dLQmdDVmRDRWxwTzkzeDdnakFMbWphXG5jZm9RWCtiWVkxbkJ3d2IvYVJxd1NiVXJiQzc3TnpGL3ZkSWpWRTRIZ0ZobVNObzNlcXFKUjJXNDA5VTJXZC9zXG5RZnhheW5MclJkdTIyeVB4OVV5KzY3OTkvaE15REZwL3hlY0lvdkwzOXR4V3FjTjZNdGw1L1lNbFNGVU5QS0JCXG44cXY4amZDa2JqU3lyMkd6ampIcVlZTnZcbi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS1cbiIsCiAgImNsaWVudF9lbWFpbCI6ICJhdXRoLXVpLXNhQG1vdXRoLW1ldHJpY3MtNDc2NjAzLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwKICAiY2xpZW50X2lkIjogIjEwNjM4MzAzMDAzNDc1NDg1OTYxMyIsCiAgImF1dGhfdXJpIjogImh0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbS9vL29hdXRoMi9hdXRoIiwKICAidG9rZW5fdXJpIjogImh0dHBzOi8vb2F1dGgyLmdvb2dsZWFwaXMuY29tL3Rva2VuIiwKICAiYXV0aF9wcm92aWRlcl94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL29hdXRoMi92MS9jZXJ0cyIsCiAgImNsaWVudF94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3JvYm90L3YxL21ldGFkYXRhL3g1MDkvYXV0aC11aS1zYSU0MG1vdXRoLW1ldHJpY3MtNDc2NjAzLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwKICAidW5pdmVyc2VfZG9tYWluIjogImdvb2dsZWFwaXMuY29tIgp9Cg==";
    FIREBASE_PROJECT_ID = "mouth-metrics-476603";
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
