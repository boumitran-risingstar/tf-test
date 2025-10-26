'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { auth } from '@/lib/firebase';
import { signOut, User } from 'firebase/auth';
import { useRouter, usePathname } from 'next/navigation';
import { Loader } from '@/components/loader';

export function Header() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged((user) => {
      setUser(user);
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  const handleLogout = async () => {
    await signOut(auth);
    router.push('/login');
  };

  const hideGetStarted = pathname === '/login' || pathname === '/signup';

  return (
    <header className="px-4 lg:px-6 h-14 flex items-center bg-header text-header-foreground border-b border-border">
      <Link href="/" className="flex items-center justify-center">
        <span className="font-semibold text-lg">MouthMetrics</span>
      </Link>
      <nav className="ml-auto flex gap-4 sm:gap-6 items-center">
        {loading ? (
          <Loader />
        ) : user ? (
          <>
            <Link
              href="/dashboard"
              className="text-sm font-medium hover:underline underline-offset-4"
            >
              Dashboard
            </Link>
            <button
              onClick={handleLogout}
              className="inline-flex h-9 items-center justify-center rounded-md bg-secondary text-secondary-foreground px-4 py-2 text-sm font-medium shadow-sm transition-colors hover:bg-secondary/90"
            >
              Logout
            </button>
          </>
        ) : (
          <>
            {!hideGetStarted && (
              <Link
                href="/login"
                className="inline-flex h-9 items-center justify-center rounded-md bg-accent text-accent-foreground px-4 py-2 text-sm font-medium shadow-sm transition-colors hover:bg-accent/90"
              >
                Get Started
              </Link>
            )}
          </>
        )}
      </nav>
    </header>
  );
}
