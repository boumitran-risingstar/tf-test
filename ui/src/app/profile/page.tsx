'use client';
import { useAuth } from '@/context/AuthContext';
import { Loader } from '@/components/loader';
import { useRouter } from 'next/navigation';

export default function ProfilePage() {
  const { user, loading } = useAuth();
  const router = useRouter();

  if (loading) {
    return <Loader />;
  }

  if (!user) {
    router.push('/login');
    return null;
  }

  return (
    <main className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Your Profile</h1>
      <div className="bg-white shadow-md rounded-lg p-6">
        <p className="mb-4">
          <span className="font-semibold">Name:</span> {user.name || 'Not set'}
        </p>
        <p className="mb-4">
          <span className="font-semibold">Email:</span> {user.email}
        </p>
      </div>
    </main>
  );
}
