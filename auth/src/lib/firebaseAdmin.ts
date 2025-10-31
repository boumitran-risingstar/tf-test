
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  // Initialize the Firebase Admin SDK.
  // In a hosted environment like Cloud Run or App Hosting,
  // the SDK is automatically configured with the project's
  // credentials.
  // For local development, you need to set up Application
  // Default Credentials.
  // See: https://cloud.google.com/docs/authentication/provide-credentials-adc
  admin.initializeApp();
}

export { admin };
