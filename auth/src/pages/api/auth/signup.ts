import { NextApiRequest, NextApiResponse } from 'next';
import { auth, appCheck } from '@/firebase/admin';

// This is the server-side endpoint for signing up new users.
// It uses the Firebase REST API to create a user with email and password.
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).end();
  }

  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    // Mint an App Check token.
    const appCheckToken = await appCheck.createToken(process.env.NEXT_PUBLIC_FIREBASE_APP_ID || '');

    // Use the Firebase REST API to create a new user.
    const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY;
    const restApiUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${apiKey}`;

    const restApiRes = await fetch(restApiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Firebase-AppCheck': appCheckToken.token,
      },
      body: JSON.stringify({
        email: email,
        password: password,
        returnSecureToken: false, // We don't need a token back, just the user ID.
      }),
    });

    const restApiData = await restApiRes.json();
    if (!restApiRes.ok) {
      throw new Error(restApiData.error.message || 'Signup failed.');
    }

    const userRecord = await auth.getUser(restApiData.localId);

    // Generate the email verification link.
    const verificationLink = await auth.generateEmailVerificationLink(email);

    // TODO: Send the verification link to the user's email address.
    console.log(`Verification link for ${email}: ${verificationLink}`);

    res.status(201).json({ uid: userRecord.uid, message: 'Signup successful. Please check your email to verify your account.' });
  } catch (error: any) {
    console.error('Error creating user:', error);
    res.status(500).json({ message: error.message || 'Internal Server Error' });
  }
}
