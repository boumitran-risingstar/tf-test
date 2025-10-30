import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
  if (!serviceAccount) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT_KEY environment variable is not set.');
  }

  const projectId = process.env.FIREBASE_PROJECT_ID;
  if (!projectId) {
    throw new Error('FIREBASE_PROJECT_ID environment variable is not set.');
  }

  let parsedServiceAccount;
  try {
    // Try parsing as base64 encoded json
    parsedServiceAccount = JSON.parse(Buffer.from(serviceAccount, 'base64').toString('utf-8'));
  } catch (e) {
    try {
      // Try parsing as plain json
      parsedServiceAccount = JSON.parse(serviceAccount);
    } catch (e2) {
      throw new Error('Failed to parse FIREBASE_SERVICE_ACCOUNT_KEY. Make sure it is a valid JSON or a base64 encoded JSON.');
    }
  }

  admin.initializeApp({
    credential: admin.credential.cert(parsedServiceAccount),
    projectId: projectId,
  });
}

export const auth = admin.auth();
