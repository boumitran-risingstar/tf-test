import { NextApiRequest, NextApiResponse } from 'next';
import { auth } from '@/firebase/admin';

// This API route sends a verification email to the currently logged-in user.
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).end();
  }

  // The user's session is managed by a secure, HTTP-only cookie.
  // We can get the user's ID directly from the session cookie on the server.
  const sessionCookie = req.cookies.session || '';

  try {
    // Verify the session cookie to get the user's decoded claims.
    const decodedClaims = await auth.verifySessionCookie(sessionCookie, true /** checkRevoked */);
    const uid = decodedClaims.uid;
    const email = decodedClaims.email;

    if (!uid || !email) {
      return res.status(401).json({ message: 'Unauthorized - Invalid session data' });
    }

    // To send a verification email, we need a Firebase ID token.
    // The Admin SDK can't generate this directly for an existing user session.
    // We will use the REST API. To do that, we first create a custom token for the user.
    const customToken = await auth.createCustomToken(uid);

    const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY;
    if (!apiKey) {
      throw new Error('Firebase API key is not configured.');
    }

    // Exchange the custom token for an ID token.
    const idTokenResponse = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: customToken, returnSecureToken: true }),
    });

    if (!idTokenResponse.ok) {
      const errorBody = await idTokenResponse.json();
      console.error('Failed to exchange custom token for ID token:', errorBody);
      throw new Error('Could not retrieve user token for verification.');
    }

    const { idToken } = await idTokenResponse.json();

    // Now, use the ID token to send the verification email.
    const verificationResponse = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ requestType: 'VERIFY_EMAIL', idToken: idToken }),
    });

    if (!verificationResponse.ok) {
      const errorBody = await verificationResponse.json();
      console.error('Failed to send verification email:', errorBody);
      throw new Error('Could not send verification email.');
    }

    res.status(200).json({ message: 'Verification email sent successfully.' });

  } catch (error: any) {
    console.error('Error sending verification email:', error);
    if (error.code === 'auth/session-cookie-expired' || error.code === 'auth/session-cookie-revoked') {
      return res.status(401).json({ message: 'Session expired. Please log in again.' });
    }
    res.status(500).json({ message: error.message || 'Internal Server Error' });
  }
}
