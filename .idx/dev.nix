# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }:
let

in
{
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.nodejs_20
    pkgs.google-cloud-sdk
    pkgs.docker
  ];
  # Sets environment variables in the workspace
  env = {
    NEXT_PUBLIC_APP_URL="https://mouthmetrics.32studio.org";
    FIREBASE_SERVICE_ACCOUNT_KEY = "ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsCiAgInByb2plY3RfaWQiOiAibW91dGgtbWV0cmljcy12MiIsCiAgInByaXZhdGVfa2V5X2lkIjogImFhYjczZTFiMTVlZTM4NGM0ZjgxYzNlZTRlYTllMzBiZDM0MTMyM2EiLAogICJwcml2YXRlX2tleSI6ICItLS0tLUJFR0lOIFBSSVZBVEUgS0VZLS0tLS1cbk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRRE1lVjU1c0k0aXBRWEJcbmRqT3Z0MTdJNVRNN3dDZzdERXMxb2JpT1E3T0RsVkdaUUdQMGNhYlVER1hEUTc1YlEvdVFmVVdZNXBTMSs3em5cblJhOW45VzlxSHdxQ3dyUTA2MzZFbHZxdW9RcG42YmZYMlBXYi92ZHQrcndVdk5OYW9acUorc3pRcTlYbXpwYVBcbkwwaHZwUTB1MEMzOWcwQVJFRDJ3V0xtTDF4bXRjZUE5RU1wWUpMb1B1MEhHcWFLaXFTMWxQemVkaFJ1RHZsSXVcbkt3SllKMjJMWUtZOHd2eS9ycERvQVhnaTRpL254dUdMcll2VGJVZXlVWUhDOVgyOWg2LzlNM2Y1VlgwNFMrMVJcbnpPNGdIdnh0bjkrMzE4ci9vZUp2ajF5QTB1dzVFM1FlZllkNFBjVkNJWUdmT3VEZ1JaaENpM3k1QUtqQXV3Tm5cbklBcm5Ia1psQWdNQkFBRUNnZjhRdjVFU20yNG1DL0lka2lUT25zK09UZkNOU05FUCtwQXBPMS9OZVg3UkxmaHBcblV5YkhzaDNvU0hnTlpzdW5rUkdOOW1XeWI2b0lqODJTTzc2Mkp0c282SlFqVSs4YVlVeSs5bmRZQ3ovQndlSEdcbmlsM29TWU5jZ1hISmFLWXIzZ2prNVdiTzZFR3ZpUmQ2THRscm5Yc0MxQVU2UUFTZ1k5RXkrbHRsUGQ5NjZTVDNcbkwwV0htVkpDR1FCSXFmUkhHN1FHeWZLaStyNlo2VU4wdm9CeStYVUF5TUx2U0pGQ1R5dnN6TWZZeVd1WjFaY2lcbnRTUVFpMzdBdHVIVjBvWXlyOW5MZjgzVUdUUEp5em50NnJpREZrZGVGblNlcE9jSTBwOWUxU2l2akVEbjBhM0VcbjlLdE1sQ3kr\nc085YlBkYkwyTXdDY3FvakpEZEpWZGI4d3dVdGJSa0NnWUVBNVdEY002WjJXRitrTVdIa09jWHRcbitHQUROQXkrN0FUTXhrQm5KUUhqdkxqU294bUR1NVFQbVdiNGZzV1JlVmNEaTIwUndyUmJwUG45RnFYbGl1bllcbnlkYXE4bWcvMHpJYU9ma2lndHpFNUhPV3pXVzJGY3hyZWVZWDRpRlFURHBxLzlTNnBXRU5vQlRiYzhYNHdNb0hcbktBMXYwWU5TNnFyenZFUWtoK3pIRlNNQ2dZRUE1RFNSMmIyMVhHSmFnWXFYZFlnRk1YelY0SXE5WU9yN1FOYURcbmI1NWJ2aS9FUFBEYm5EY1J4OVoyNjIxcmlFeFZJNE52WVV4d1h3WFJzM0daQnZlK3FtWlowTHRPVFlQNXhGR0JcbmdiYzVpRHVLR1VwKzQybXFuSXpZZVBQMGc4M3gzd0lUM3JvcnZteTFNZ1RxaUJiT1dzMU9GdG1tcVVFRHlSemxcbmhQcHR3dGNDZ1lFQTJNNXh0Rnc5OWhBSWlTaW02TGlkMHFzbHUvZmtLZi9yY2VRRDJpWHNGVUI0ei9MWTRkN3pcbjA2SlJkTG5YWStLTUZpZzBwbDJGVmUxNGZBUzRiMUhUT0F3d3JrazlNcWxqd3JJcUhaa0FmWktIMG9LMTFlclBcbkYzd1Z6UWFCK0Zzck1iN240Rk5ZNXB0d1JnQzB1N3o1Z0xFYXBPVEU1Y3hKN3dSVnB5aDFrQk1DZ1lFQTRkeWxcbi9qd2xKQ3EwS1VKaVpaRWFrc0JiYnNIaWJlb2tneWZOTHN3dFFTOUZxb3M0MElRd3RQa3UraFJ5T1pSVEw3TUdcbnFlWmQwYTZRdm1uUWEzVUk0TjRzUnNzYjFOeXFlQU96aWc4dWdnZHJ4MXhUK2dDN08vYXF5Z3VxRmtuZStqbTBcbk1OMVNMa2FwajdnTjZHT3FHWFRadFFQMlQ4NXBVTU9vNXRSMWprRUNnWUVBa3BramtXemxGOVU0ZTZXSml0RCtcbk5ZamF0cnpUaXF6eVh3SkZ4RnFKdVN2c3dtSWVqTjVIVWhJajB3TXpEajlNVzhTNmVraDI4NnRJaCs1a085bThcbnUwNkYvWWczZElVZGZSczRtWDd2SndWcWVQdnl2M1M3b1grVkVNb2Q5cHVsaHo5OXZpekhpNkQrL3RtMDNkdlNcbkFXRGhDQWdpUUpsekxTcXB6cGtlbEs0PVxuLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLVxuIiwKICAiY2xpZW50X2VtYWlsIjogImZpcmViYXNlLWlkeC1zYUBtb3V0aC1tZXRyaWNzLXYyLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwKICAiY2xpZW50X2lkIjogIjExNDE5Mjk3NjUxOTEwNTU2NDc4MiIsCiAgImF1dGhfdXJpIjogImh0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbS9vL29hdXRoMi9hdXRoIiwKICAidG9rZW5fdXJpIjogImh0dHBzOi8vb2F1dGgyLmdvb2dsZWFwaXMuY29tL3Rva2VuIiwKICAiYXV0aF9wcm92aWRlcl94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL29hdXRoMi92MS9jZXJ0cyIsCiAgImNsaWVudF94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3JvYm90L3YxL21ldGFkYXRhL3g1MDkvZmlyZWJhc2UtaWR4LXNhJTQwbW91dGgtbWV0cmljcy12Mi5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsCiAgInVuaXZlcnNlX2RvbWFpbiI6ICJnb29nbGVhcGlzLmNvbSIKfQo=";
    NEXT_PUBLIC_FIREBASE_API_KEY = "AIzaSyDETvhPci48XeLxI-QExYTK8i-J8mjZncY";
     # The App ID of your web app. Found in the Firebase console.
    # This is required by the auth service to mint App Check tokens.
    NEXT_PUBLIC_FIREBASE_APP_ID = "1:23307517023:web:cf33c4c05ecd09804a6fea"; # <-- PASTE YOUR APP ID HERE
    # The reCAPTCHA v3 site key for App Check. You can find this in your Firebase project settings.
    # NOTE: reCAPTCHA Enterprise is now the recommended solution for web apps.
    NEXT_PUBLIC_RECAPTCHA_ENTERPRISE_SITE_KEY = "6Lehr_0rAAAAAADDqnZQa4Xgcz3yc7tAwouSOcpv";
    NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN = "mouth-metrics-v2.firebaseapp.com";
    NEXT_PUBLIC_FIREBASE_PROJECT_ID = "mouth-metrics-v2";
    NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET = "mouth-metrics-v2.appspot.com";
    NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID = "23307517023";
  };
  # Enable the Docker daemon
  services.docker.enable = true;
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "google.cloud-code"
      "dbaeumer.vscode-eslint" # For linting TypeScript and JavaScript
      "esbenp.prettier-vscode" # For code formatting
    ];
    # Enable previews
    previews = {
      enable = true ;
      previews = {
        web = {
          # FIX: Changed command array to a single string to correctly resolve the 'next' command via npm
          command = [ "sh" "-c" "npm run dev -- --port $PORT" ];

          env = {
            NEXT_PUBLIC_USERS_API_URL = "http://localhost:8080";
            NEXT_PUBLIC_AUTH_API_URL = "http://localhost:3001";
          };
          manager = "web";
          cwd = "ui";
        };
      };
    };
    # Workspace lifecycle hooks
    workspace = {
      # Runs when a workspace is first created
      onCreate = {
        install-auth = "npm install --prefix auth";
        install-ui = "npm install --prefix ui";
        install-users-api = "npm install --prefix users-api";
      };
      # Runs every time the workspace is (re)started
      onStart = {
        start-users-api = ''
          echo "Starting users-api (port 8080)..."
          (cd users-api && PORT=8080 npm start )
        '';
        start-auth-service = ''
          echo "Starting auth service (port 3001)..."
          # Ensure the required env variable is passed to the auth service process
          (cd auth && NEXT_PUBLIC_USERS_API_URL="http://localhost:8080" PORT=3001 npm run dev )
          
          echo "Backend services are starting. The UI preview will attempt to connect shortly."
        '';
      };
    };
  };
}
