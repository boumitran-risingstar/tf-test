'use client';
import { useAuth } from '@/context/AuthContext';
import { Button } from '@/components/button';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

export default function DashboardPageClient() {
  const { user, loading, logout } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !user) {
      router.push('/login');
    }
  }, [user, loading, router]);

  const handleLogout = async () => {
    await logout();
    router.push('/login');
  };

  if (loading || !user) {
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
