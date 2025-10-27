
import { NextRequest, NextResponse } from 'next/server';
import { admin } from '@/lib/firebaseAdmin';
import { GoogleAuth } from 'google-auth-library';

const usersApiUrl = process.env.NEXT_PUBLIC_USERS_API_URL;

export async function GET(req: NextRequest, { params }: { params: { uid: string } }) {
  try {
    const idToken = req.headers.get('Authorization')?.split('Bearer ')[1];
    if (!idToken) {
      return NextResponse.json({ message: 'Unauthorized' }, { status: 401 });
    }

    const decodedToken = await admin.auth().verifyIdToken(idToken);
    if (decodedToken.uid !== params.uid) {
      return NextResponse.json({ message: 'Forbidden' }, { status: 403 });
    }

    if (!usersApiUrl) {
        throw new Error("NEXT_PUBLIC_USERS_API_URL is not defined");
    }

    // Initialize Google Auth client
    const auth = new GoogleAuth();
    
    // Fetch the identity token
    const client = await auth.getIdTokenClient(usersApiUrl);
    
    // Get the actual token
    const clientHeaders = await client.getRequestHeaders();
    
    const res = await fetch(`${usersApiUrl}/users/${params.uid}`, {
        headers: {
            Authorization: clientHeaders['Authorization'],
        },
    });

    const data = await res.json();

    return NextResponse.json(data, { status: res.status });
  } catch (error) {
    console.error('Error fetching user:', error);
    return NextResponse.json({ message: 'Internal Server Error' }, { status: 500 });
  }
}
