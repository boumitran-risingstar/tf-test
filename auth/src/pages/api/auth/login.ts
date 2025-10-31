
import { NextApiRequest, NextApiResponse } from 'next';
import { auth } from '@/firebase/admin';
import { setSession } from '@/lib/session';

// Securely sign in with password and exchange for a session cookie.
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).end();
  }

  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    // Use the Firebase REST API to verify the password.
    const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY;
    const restApiUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`;

    const restApiRes = await fetch(restApiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email,
        password,
        returnSecureToken: true,
      }),
    });

    const restApiData = await restApiRes.json();
    if (!restApiRes.ok) {
      throw new Error(restApiData.error.message || 'Authentication failed.');
    }

    // Exchange the ID token for a session cookie.
    const idToken = restApiData.idToken;
    const expiresIn = 60 * 60 * 24 * 5 * 1000; // 5 days
    const sessionCookie = await auth.createSessionCookie(idToken, { expiresIn });

    setSession(res, sessionCookie);
    res.status(200).json({ status: 'success' });

  } catch (error: any) {
    console.error('Login failed:', error.message);
    res.status(401).json({ message: error.message || 'Login failed.' });
  }
}
