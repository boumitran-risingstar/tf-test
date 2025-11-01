import { getAuth } from 'firebase-admin/auth';
import { app, appCheck } from '@/firebase/admin'; // Consolidated to modern, modular admin app
import { NextApiRequest, NextApiResponse } from 'next';

const PHONE_VERIFY_CODE_API_URL =
  'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse,
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const appCheckTokenFromClient = req.headers['x-firebase-appcheck'];
  if (!appCheckTokenFromClient) {
    return res.status(401).json({ error: 'App Check token not found.' });
  }

  try {
    await appCheck.verifyToken(appCheckTokenFromClient as string);
  } catch (err) {
    return res.status(401).json({ error: 'Invalid App Check token.' });
  }

  const { sessionInfo, code } = req.body;
  if (!sessionInfo || !code) {
    return res.status(400).json({ error: 'Session info and code are required' });
  }

  try {
    const appCheckTokenForFirebase = await appCheck.createToken(process.env.NEXT_PUBLIC_FIREBASE_APP_ID || '');

    const response = await fetch(
      `${PHONE_VERIFY_CODE_API_URL}?key=${process.env.NEXT_PUBLIC_FIREBASE_API_KEY}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Firebase-AppCheck': appCheckTokenForFirebase.token,
        },
        body: JSON.stringify({
          sessionInfo: sessionInfo,
          code: code,
        }),
      },
    );

    const data = await response.json();

    if (!response.ok) {
      return res.status(data.error.code || 500).json({ error: data.error.message });
    }

    const idToken = data.idToken;
    if (!idToken) {
      throw new Error('ID token not found in Firebase response.');
    }

    const expiresIn = 60 * 60 * 24 * 5 * 1000; // 5 days

    // Using the modern 'app' instance for getAuth, consistent with session verification
    const sessionCookie = await getAuth(app).createSessionCookie(idToken, {
      expiresIn,
    });

    const options = {
      maxAge: expiresIn / 1000,
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      path: '/',
    };

    res.setHeader(
      'Set-Cookie',
      `session=${sessionCookie}; Max-Age=${options.maxAge}; Path=${options.path}; HttpOnly; ${options.secure ? 'Secure' : ''}`
    );
    res.status(200).json({ status: 'success' });
  } catch (error: any) {
    console.error('Error in phone-verify:', error);
    res.status(500).json({ error: error.message || 'Something went wrong' });
  }
}
