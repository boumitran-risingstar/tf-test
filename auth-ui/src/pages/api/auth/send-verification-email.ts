import { NextApiRequest, NextApiResponse } from 'next';
import { auth } from '@/firebase/admin';
import { cookies } from 'next/headers';
import { lucia } from '@/lib/lucia';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).end();
  }

  const sessionId = req.cookies[lucia.sessionCookieName] ?? null;
  if (!sessionId) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  const { session } = await lucia.validateSession(sessionId);
  if (!session) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  try {
    // We need a Firebase ID token to send the verification email.
    // The Admin SDK cannot do this directly. We must use the REST API.
    // To do that, we need to create a custom token and then exchange it for an ID token.
    const customToken = await auth.createCustomToken(session.userId);

    const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY;

    // Exchange custom token for an ID token
    const idTokenResponse = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: customToken, returnSecureToken: true }),
    });

    if (!idTokenResponse.ok) {
      throw new Error('Failed to exchange custom token for ID token');
    }

    const { idToken } = await idTokenResponse.json();

    // Now, use the ID token to send the verification email
    const verificationResponse = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ requestType: 'VERIFY_EMAIL', idToken: idToken }),
    });

    if (!verificationResponse.ok) {
      throw new Error('Failed to send verification email');
    }

    res.status(200).json({ message: 'Verification email sent.' });

  } catch (error: any) {
    console.error('Error sending verification email:', error);
    res.status(500).json({ message: error.message || 'Internal Server Error' });
  }
}
