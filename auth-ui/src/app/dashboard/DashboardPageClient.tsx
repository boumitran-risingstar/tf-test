'use client';
import { useAuth } from '@/context/AuthContext';
import { Button } from '@/components/button';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import toast from 'react-hot-toast';

export default function DashboardPageClient() {
  const { user, loading, logout, sendVerificationEmail } = useAuth();
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

  const handleSendVerification = async () => {
    try {
      await sendVerificationEmail();
      toast.success('Verification email sent! Please check your inbox.');
    } catch (error: any) {
      toast.error(error.message || 'Failed to send verification email. Please try again.');
    }
  };

  if (loading || !user) {
    return <div>Loading...</div>;
  }

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-background">

      {/* --- Verification Banner --- */}
      {!user.email_verified && (
        <div className="w-full max-w-md p-4 mb-4 text-center bg-yellow-100 border border-yellow-400 rounded-lg">
          <p className="font-semibold text-yellow-800">Please verify your email address.</p>
          <p className="text-sm text-yellow-700">A verification link has been sent to {user.email}.</p>
          <Button 
            onClick={handleSendVerification} 
            className="mt-2 text-sm"
            variant='link'
          >
            Resend Verification Email
          </Button>
        </div>
      )}
      {/* --- End Verification Banner --- */}

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
