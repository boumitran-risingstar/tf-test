import admin from 'firebase-admin';
import { App } from 'firebase-admin/app';

export const getAdminApp = (): App => {
  if (admin.apps.length > 0 && admin.apps[0]) {
    return admin.apps[0];
  }

  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
  if (!serviceAccount) {
    throw new Error('Missing FIREBASE_SERVICE_ACCOUNT_KEY environment variable.');
  }

  const decodedServiceAccount = Buffer.from(serviceAccount, 'base64').toString('utf-8');

  return admin.initializeApp({
    credential: admin.credential.cert(JSON.parse(decodedServiceAccount)),
  });
};