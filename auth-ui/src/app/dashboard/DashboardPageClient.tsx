'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { auth } from '@/lib/firebase';
import { onAuthStateChanged, User } from 'firebase/auth';
import { Button } from '@/components/button';
import toast from 'react-hot-toast';

export default function DashboardPageClient() {
  const router = useRouter();
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (user) {
        setUser(user);
        syncUser(user); // Call syncUser when user is authenticated
      } else {
        window.location.href = '/login';
      }
    });

    return () => unsubscribe();
  }, [router]);

  const syncUser = async (user: User) => {
    try {
      const idToken = await user.getIdToken();
      const res = await fetch(`/api/users/${user.uid}`, {
        headers: {
          'Authorization': `Bearer ${idToken}`,
        },
      });

      if (res.status === 404) {
        // User not found, so create them
        const createRes = await fetch('/api/users', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${idToken}`,
          },
          body: JSON.stringify({
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
          }),
        });

        if (createRes.ok) {
          const newUser = await createRes.json();
          console.log('Created user:', newUser);
        } else {
          const errorData = await createRes.json();
          const message = errorData.message || createRes.statusText;
          toast.error(`Failed to create user: ${message}`);
        }
      } else if (res.ok) {
        const userData = await res.json();
        console.log('User data:', userData);
      } else {
        const errorData = await res.json();
        const message = errorData.message || res.statusText;
        toast.error(`Failed to retrieve user data: ${message}`);
      }
    } catch (error) {
      console.error('Failed to sync user', error);
      toast.error('Failed to sync user');
    }
  };


  const handleLogout = async () => {
    if (auth.currentUser) {
        await auth.signOut();
    }
    window.location.href = '/login';
  };

  if (!user) {
    return <div>Loading...</div>;
  }

  return (
    <div className="flex items-center justify-center min-h-screen bg-background">
      <div className="w-full max-w-md p-8 space-y-6 bg-white rounded-lg shadow-md">
        <div className="text-center">
          <h1 className="text-3xl font-bold">Welcome to Your Dashboard</h1>
          <p className="text-gray-500">You are logged in as {user.email}</p>
        </div>
        <Button onClick={handleLogout} className="w-full">Logout</Button>
      </div>
    </div>
  );
}
