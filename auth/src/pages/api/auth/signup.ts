import { NextApiRequest, NextApiResponse } from 'next';
import { auth } from '@/firebase/admin';

// This is the server-side endpoint for signing up new users.
// It uses the Firebase Admin SDK to create a user with email and password.
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).end();
  }

  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required.' });
  }

  try {
    // Use the Firebase Admin SDK to create a new user.
    const userRecord = await auth.createUser({
      email: email,
      password: password,
      emailVerified: false, // Explicitly set emailVerified to false
    });

    // Generate the email verification link.
    const verificationLink = await auth.generateEmailVerificationLink(email);

    // TODO: Send the verification link to the user's email address.
    // You can use a library like Nodemailer or an email service like SendGrid to send the email.
    // For example (using a placeholder function):
    // await sendVerificationEmail(email, verificationLink);
    console.log(`Verification link for ${email}: ${verificationLink}`); // Log for debugging


    // Send back a success response.
    // We don't automatically log the user in for security reasons.
    // The client will redirect to the login page.
    res.status(201).json({ uid: userRecord.uid, message: 'Signup successful. Please check your email to verify your account.' });
  } catch (error: any) {
    // Handle potential errors, like the email already being in use.
    console.error('Error creating user:', error);
    res.status(500).json({ message: error.message || 'Internal Server Error' });
  }
}
