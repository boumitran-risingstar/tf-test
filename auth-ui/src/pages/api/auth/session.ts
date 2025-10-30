import { NextApiRequest, NextApiResponse } from 'next';
import { getSession } from '@/lib/session';

// This is the server-side endpoint for retrieving the current session.
// It verifies the session cookie and returns the user's data if the session is valid.
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    return res.status(405).end();
  }

  const session = await getSession(req);

  if (session) {
    res.status(200).json({ session });
  } else {
    res.status(401).json({ session: null });
  }
}
