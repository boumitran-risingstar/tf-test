import { NextResponse } from 'next/server';
import { GoogleAuth } from 'google-auth-library';
import { getAuth } from 'firebase-admin/auth';
import { getAdminApp } from '@/firebase/admin-config';

async function getUserIdToken(uid: string) {
  const customToken = await getAuth(getAdminApp()).createCustomToken(uid);
  const res = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=${process.env.NEXT_PUBLIC_FIREBASE_API_KEY}`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        token: customToken,
        returnSecureToken: true
      })
    });

  const data = await res.json();
  return data.idToken;
}

export async function POST(request: Request) {
  try {
    const auth = new GoogleAuth({
      scopes: 'https://www.googleapis.com/auth/cloud-platform',
    });

    const { user } = await request.json();
    const idToken = await getUserIdToken(user.uid);

    const client = await auth.getIdTokenClient(process.env.USERS_API_URL || '');
    const res = await client.request({
      url: `${process.env.USERS_API_URL}/api/users`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${idToken}`
      },
      data: {
        name: user.displayName || 'Anonymous',
        email: user.email,
        uid: user.uid
      }
    });

    return NextResponse.json(res.data, { status: res.status });
  } catch (error) {
    console.error('Failed to call users-api', error);
    return NextResponse.json({ message: 'Failed to call users-api' }, { status: 500 });
  }
}