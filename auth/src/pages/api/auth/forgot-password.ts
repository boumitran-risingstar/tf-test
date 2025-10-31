import { NextApiRequest, NextApiResponse } from 'next';
import { auth } from '@/firebase/admin';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).end();
  }

  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ message: 'Email is required.' });
    }
    const link = await auth.generatePasswordResetLink(email);
    // TODO: Send this link to the user via email
    console.log('Password reset link:', link);
    return res.status(200).json({ success: true });
  } catch (error: any) {
    return res.status(400).json({ message: error.message });
  }
}
