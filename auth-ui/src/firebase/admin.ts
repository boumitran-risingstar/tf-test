import * as admin from 'firebase-admin';

// When GOOGLE_APPLICATION_CREDENTIALS is set, initializeApp() automatically
// uses the service account key file. In production, it uses the
// attached service account identity.
if (!admin.apps.length) {
  admin.initializeApp();
}

export const auth = admin.auth();
