
/** @type {import('next').NextConfig} */
const nextConfig = {
  async rewrites() {
    const firebaseProject = process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID;
    if (!firebaseProject) {
      // This warning will be visible during the build process if the variable is not set.
      console.warn('WARNING: NEXT_PUBLIC_FIREBASE_PROJECT_ID is not set. Firebase auth rewrites will not be configured.');
      return [];
    }
    return [
      {
        source: '/__/auth/:path*',
        // The destination is the Firebase project's universal auth backend.
        // This is NOT your custom domain, which would cause an infinite loop.
        destination: `https://${firebaseProject}.firebaseapp.com/__/auth/:path*`,
      },
    ];
  },
};

export default nextConfig;
