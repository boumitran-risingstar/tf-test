import { NextApiRequest, NextApiResponse } from 'next';
import { auth } from '@/firebase/admin';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).end();
  }

  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    // Create the user with the Admin SDK
    const userRecord = await auth.createUser({
      email: email,
      password: password,
    });

    // --- Start: Trigger Verification Email ---
    const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY;

    // 1. Exchange email/password for an ID token.
    const idTokenResponse = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, returnSecureToken: true }),
    });

    if (idTokenResponse.ok) {
      const { idToken } = await idTokenResponse.json();

      // 2. Use the ID token to send the verification email.
      const verificationResponse = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${apiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ requestType: 'VERIFY_EMAIL', idToken: idToken }),
      });

      if (!verificationResponse.ok) {
        // Log if sending the email fails, but don't block signup.
        console.error('Failed to send verification email', await verificationResponse.json());
      }
    } else {
      // Log if getting the ID token fails.
      console.error('Failed to get ID token for verification', await idTokenResponse.json());
    }
    // --- End: Trigger Verification Email ---

    // The main signup operation is still considered successful.
    res.status(201).json({ uid: userRecord.uid });

  } catch (error: any) {
    console.error('Error creating user:', error);
    res.status(500).json({ message: error.message || 'Internal Server Error' });
  }
}
