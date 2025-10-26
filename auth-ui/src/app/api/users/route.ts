
import { NextResponse } from 'next/server';
import { GoogleAuth } from 'google-auth-library';

export async function GET() {
  try {
    const auth = new GoogleAuth({
      scopes: 'https://www.googleapis.com/auth/cloud-platform',
    });

    const client = await auth.getIdTokenClient(process.env.USERS_API_URL || '');
    const res = await client.request({ url: process.env.USERS_API_URL || '' });

    return NextResponse.json(res.data, { status: res.status });
  } catch (error) {
    console.error('Failed to call users-api', error);
    return NextResponse.json({ message: 'Failed to call users-api' }, { status: 500 });
  }
}
