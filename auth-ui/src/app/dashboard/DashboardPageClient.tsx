'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { auth } from '@/firebase/config';
import { onAuthStateChanged } from 'firebase/auth';
import { Button } from '@/components/button';
import toast from 'react-hot-toast';

export default function DashboardPageClient() {
  const router = useRouter();
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (user) {
        setUser(user);
      } else {
        window.location.href = '/login';
      }
    });

    return () => unsubscribe();
  }, [router]);

  const handleLogout = async () => {
    await auth.signOut();
    toast.success('Logged out successfully!');
    window.location.href = '/login';
  };

  const handleApiCall = async () => {
    try {
      const res = await fetch('/api/users', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ user }),
      });
      if (res.ok) {
        const data = await res.json();
        toast.success(`API Response: ${JSON.stringify(data)}`);
      } else {
        toast.error(`API Error: ${res.statusText}`);
      }
    } catch (error) {
      console.error('Failed to call API', error);
      toast.error('Failed to call API');
    }
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
        <Button onClick={handleApiCall} className="w-full">Call API</Button>
        <Button onClick={handleLogout} className="w-full">Logout</Button>
      </div>
    </div>
  );
}
