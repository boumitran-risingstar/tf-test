import { NextApiRequest, NextApiResponse } from 'next';
import { clearSession } from '@/lib/session';

// This is the server-side endpoint for logging out.
// It clears the session cookie.
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).end();
  }

  clearSession(res);

  res.status(200).json({ status: 'success' });
}
