
import { serialize, parse } from 'cookie';
import { NextApiRequest, NextApiResponse } from 'next';
import { auth } from '@/firebase/admin';

const SESSION_COOKIE_NAME = 'session';
const MAX_AGE = 60 * 60 * 24 * 7; // 1 week

export function setSession(res: NextApiResponse, session: string) {
  const cookie = serialize(SESSION_COOKIE_NAME, session, {
    httpOnly: true,
    secure: true, // Must be true for SameSite='none'
    sameSite: 'none', // Required for cross-site cookie context (iframes)
    path: '/',
    maxAge: MAX_AGE,
  });

  res.setHeader('Set-Cookie', cookie);
}

export function clearSession(res: NextApiResponse) {
  const cookie = serialize(SESSION_COOKIE_NAME, '', {
    httpOnly: true,
    secure: true, // Must be true for SameSite='none'
    sameSite: 'none', // Required for cross-site cookie context (iframes)
    path: '/',
    maxAge: -1,
  });

  res.setHeader('Set-Cookie', cookie);
}

export async function getSession(req: NextApiRequest) {
    const cookies = parse(req.headers.cookie || '');
    const sessionCookie = cookies[SESSION_COOKIE_NAME];

    if (!sessionCookie) {
        return null;
    }

    try {
        const decodedClaims = await auth.verifySessionCookie(sessionCookie, true);
        return decodedClaims;
    } catch (error) {
        console.error("Error verifying session cookie:", error);
        return null;
    }
}
