'use client';

import Link from 'next/link';
import { useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { useAuth } from '@/context/AuthContext'; // Import the new hook
import { Loader } from '@/components/loader';

// A simplified user type for the client-side
interface User {
  uid: string;
  email?: string;
  name?: string;
  picture?: string;
}

export function Header() {
  const { user, loading, logout } = useAuth(); // Use the new auth context
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const router = useRouter();
  const pathname = usePathname();

  const handleLogout = async () => {
    await logout();
    setDropdownOpen(false);
    router.push('/login'); // Redirect to login after logout
  };

  const hideGetStarted = pathname === '/login' || pathname === '/signup';

  const getInitials = (user: User) => {
    // Use name or email from the new user object
    if (user.name) {
      return user.name.charAt(0).toUpperCase();
    }
    if (user.email) {
      return user.email.charAt(0).toUpperCase();
    }
    return '?';
  };

  return (
    <header className="sticky top-0 z-50 px-4 lg:px-6 h-14 flex items-center bg-header bg-opacity-90 backdrop-blur-sm text-header-foreground border-b border-border">
      <Link href={user ? "/dashboard" : "/"} className="flex items-center justify-center">
        <span className="font-semibold text-lg">MouthMetrics</span>
      </Link>
      <nav className="ml-auto flex gap-4 sm:gap-6 items-center">
        {loading ? (
          <Loader />
        ) : user ? (
          <div className="relative">
            <button
              onClick={() => setDropdownOpen(!dropdownOpen)}
              className="flex items-center justify-center h-9 w-9 rounded-full bg-accent text-accent-foreground"
            >
              {getInitials(user)}
            </button>
            {dropdownOpen && (
              <div className="absolute right-0 mt-2 w-48 bg-white rounded-md overflow-hidden shadow-xl z-10 border border-border">
                <Link
                  href="/profile"
                  className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                  onClick={() => setDropdownOpen(false)}
                >
                  Profile
                </Link>
                <button
                  onClick={handleLogout}
                  className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  Logout
                </button>
              </div>
            )}
          </div>
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
