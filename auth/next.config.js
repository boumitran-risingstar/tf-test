/** @type {import('next').NextConfig} */
const nextConfig = {
  // The backend is a separate service, so we need to proxy API requests
  // to the backend service.
  async rewrites() {
    let firebaseProject = process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID;
    if (!firebaseProject) {
      try {
        const serviceAccount = JSON.parse(Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_KEY, 'base64').toString());
        firebaseProject = serviceAccount.project_id;
      } catch (e) {
        console.warn('WARNING: Could not parse FIREBASE_SERVICE_ACCOUNT_KEY. Firebase auth rewrites will not be configured.');
        return [];
      }
    }
    return [
      {
        source: '/api/:path*',
        destination: `${process.env.NEXT_PUBLIC_USERS_API_URL}/:path*`,
      },
      {
        source: '/__/auth/:path*',
        destination: `https://${firebaseProject}.firebaseapp.com/__/auth/:path*`,
      },
      {
        source: '/v1/:path*',
        destination: 'https://identitytoolkit.googleapis.com/v1/:path*',
      },
    ]
  },
};

module.exports = nextConfig;
