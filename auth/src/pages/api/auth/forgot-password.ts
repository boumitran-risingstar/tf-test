import { NextApiRequest, NextApiResponse } from 'next';
import { appCheck } from '@/firebase/admin';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).end();
  }

  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ message: 'Email is required.' });
    }

    // Mint an App Check token.
    const appCheckToken = await appCheck.createToken(process.env.NEXT_PUBLIC_FIREBASE_APP_ID || '');

    const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY;
    const restApiUrl = `https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${apiKey}`;

    const restApiRes = await fetch(restApiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Firebase-AppCheck': appCheckToken.token,
      },
      body: JSON.stringify({
        requestType: 'PASSWORD_RESET',
        email: email,
      }),
    });

    if (!restApiRes.ok) {
      const errorData = await restApiRes.json();
      throw new Error(errorData.error.message || 'Failed to send password reset email.');
    }

    // The REST API handles sending the email, so we just need to confirm success.
    console.log('Password reset email sent for:', email);
    return res.status(200).json({ success: true });
  } catch (error: any) {
    return res.status(400).json({ message: error.message });
  }
}
