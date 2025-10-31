import { admin } from '@/lib/firebaseAdmin';
import { NextResponse } from 'next/server';

export async function POST(req: Request) {
  try {
    const { email } = await req.json();
    const link = await admin.auth().generatePasswordResetLink(email);
    // TODO: Send this link to the user via email
    console.log('Password reset link:', link);
    return NextResponse.json({ success: true });
  } catch (error: any) {
    return new NextResponse(JSON.stringify({ message: error.message }), { status: 400 });
  }
}
