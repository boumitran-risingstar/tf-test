/** @type {import('next').NextConfig} */
const nextConfig = {
  // The backend is a separate service, so we need to proxy API requests
  // to the backend service.
  async rewrites() {
    return [
      {
        source: '/api/users/:path*',
        destination: `${process.env.NEXT_PUBLIC_USERS_API_URL}/:path*`,
      },
      {
        source: '/api/auth/:path*',
        destination: `${process.env.NEXT_PUBLIC_AUTH_API_URL}/api/auth/:path*`,
      },
      {
        source: '/__/auth/:path*',
        destination: `https://${process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID}.firebaseapp.com/__/auth/:path*`,
      },
      {
        source: '/v1/:path*',
        destination: 'https://identitytoolkit.googleapis.com/v1/:path*',
      },
    ]
  },
};

module.exports = nextConfig;
