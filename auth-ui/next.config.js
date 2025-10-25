/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  experimental: {
    allowedDevOrigins: [
      // Standard Google/Firebase Development Hosts (Wildcard covers most cases)
      "https://cloudworkstations.dev",
      "http://cloudworkstations.dev",
      "https://*.google.com",
      "https://*.cloud.google.com",
      "https://*.cloud.goog",
      "https://*.cloudworkstations.dev", // This should cover the domain
      "http://*.cloudworkstations.dev",   // This should cover the domain
      "https://*.firebase.dev",
      "https://*.firebaseapp.com",
      "http://*.firebaseapp.com:3000",
      "https://*.run.app",
      "https://*.web.app",
      "http://*.web.app:3000",
      "http://localhost:4000",
      "http://127.0.0.1:4000",

      // *** CRITICAL DEBUG ADDITION ***
      // Adding the exact, full domain reported in your error message for both protocols
      "https://3000-firebase-tf-test-1761187186905.cluster-6dx7corvpngoivimwvvljgokdw.cloudworkstations.dev",
      "http://3000-firebase-tf-test-1761187186905.cluster-6dx7corvpngoivimwvvljgokdw.cloudworkstations.dev",

      // *** NEW WIDLER WILDCARD ADDITIONS ***
      // This often covers nested subdomains in GCP environments.
      "https://*.cluster-6dx7corvpngoivimwvvljgokdw.cloudworkstations.dev",
      "http://*.cluster-6dx7corvpngoivimwvvljgokdw.cloudworkstations.dev",
    ],
  },
};

module.exports = nextConfig;
