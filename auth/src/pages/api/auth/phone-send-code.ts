import { NextApiRequest, NextApiResponse } from 'next';
import { appCheck } from '@/firebase/admin';

const PHONE_SEND_CODE_API_URL =
  'https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse,
) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method Not Allowed' });
    return;
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

  const { phoneNumber } = req.body;

  if (!phoneNumber) {
    res.status(400).json({ error: 'Phone number is required' });
    return;
  }

  try {
    const appCheckTokenForFirebase = await appCheck.createToken(process.env.NEXT_PUBLIC_FIREBASE_APP_ID || '');

    const response = await fetch(
      `${PHONE_SEND_CODE_API_URL}?key=${process.env.NEXT_PUBLIC_FIREBASE_API_KEY}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Firebase-AppCheck': appCheckTokenForFirebase.token,
        },
        body: JSON.stringify({
          phoneNumber: phoneNumber,
        }),
      },
    );

    const data = await response.json();

    if (!response.ok) {
      res.status(data.error.code || 500).json({ error: data.error.message });
      return;
    }

    res.status(200).json({ sessionInfo: data.sessionInfo });
  } catch (error: any) {
    console.error('Error in phone-send-code:', error);
    res.status(500).json({ error: error.message || 'Something went wrong' });
  }
}
