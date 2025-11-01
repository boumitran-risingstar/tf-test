import * as admin from 'firebase-admin';
import { getAppCheck } from 'firebase-admin/app-check';

if (!admin.apps.length) {
  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
  if (!serviceAccount) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT_KEY environment variable is not set.');
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

  const projectId = parsedServiceAccount.project_id;
  if (!projectId) {
    throw new Error('Failed to get project_id from FIREBASE_SERVICE_ACCOUNT_KEY.');
  }

  admin.initializeApp({
    credential: admin.credential.cert(parsedServiceAccount),
    projectId: projectId,
  });
}

export const auth = admin.auth();
export const appCheck = getAppCheck();
