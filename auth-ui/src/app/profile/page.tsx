'use client';

import { useState, useEffect } from 'react';
import { auth } from '@/lib/firebase';
import { User } from 'firebase/auth';
import { Loader } from '@/components/loader';

export default function ProfilePage() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged((user) => {
      if (user) {
        setUser(user);
      } else {
        // Redirect to login if not authenticated
        window.location.href = '/login';
      }
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  if (loading) {
    return <Loader />;
  }

  if (!user) {
    return null; // Or a message indicating the user is not logged in
  }

  return (
    <main className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Your Profile</h1>
      <div className="bg-white shadow-md rounded-lg p-6">
        <p className="mb-4">
          <span className="font-semibold">Name:</span> {user.displayName || 'Not set'}
        </p>
        <p className="mb-4">
          <span className="font-semibold">Email:</span> {user.email}
        </p>
      </div>
    </main>
  );
}
