import { NextApiRequest, NextApiResponse } from 'next';
import { auth } from '@/firebase/admin';

// This is the server-side endpoint for signing up new users.
// It uses the Firebase Admin SDK to create a user with email and password.
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).end();
  }

  const { email, pass } = req.body;

  if (!email || !pass) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    // Use the Firebase Admin SDK to create a new user.
    const userRecord = await auth.createUser({
      email: email,
      password: pass,
    });

    // Send back a success response.
    // We don't automatically log the user in for security reasons.
    // The client will redirect to the login page.
    res.status(201).json({ uid: userRecord.uid });
  } catch (error: any) {
    // Handle potential errors, like the email already being in use.
    console.error('Error creating user:', error);
    res.status(500).json({ message: error.message || 'Internal Server Error' });
  }
}
