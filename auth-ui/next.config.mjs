
import withPWA from '@ducanh2912/next-pwa';

const nextConfig = {
  reactStrictMode: true,
};

const pwaConfig = withPWA({
  dest: 'public',
  register: true,
  skipWaiting: true,
  disable: process.env.NODE_ENV === 'development',
  fallbacks: {
    document: '/~offline',
  },
  cacheOnFrontEndNav: true,
  aggressiveFrontEndNavCaching: true,
  cacheStartUrl: true,
  dynamicStartUrl: true,
  workboxOptions: {
    // Exclude specific routes from caching
    exclude: ['/api/auth/.*\, '/api/users/.*\],  
  },
  // Add screenshots for a better PWA experience
  screenshots: [
    {
      src: '/screenshots/signup-desktop.png',
      sizes: '1280x720',
      type: 'image/png',
      form_factor: 'wide',
      label: 'Auth UI Signup',
    },
    {
      src: '/screenshots/signup-mobile.png',
      sizes: '720x1280',
      type: 'image/png',
      form_factor: 'narrow',
      label: 'Auth UI Signup',
    },
  ],
});

export default pwaConfig(nextConfig);
