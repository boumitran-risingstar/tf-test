'use client';
import { createContext, useContext, useEffect, useState, ReactNode } from 'react';

// This is a simplified version of the user object for the client-side.
interface User {
  uid: string;
  email?: string;
  name?: string;
  picture?: string;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  signup: (email: string, password: string) => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // On initial load, check for a valid server-side session.
    const checkSession = async () => {
      setLoading(true);
      try {
        const res = await fetch('/api/auth/session');
        if (res.ok) {
          const { session } = await res.json();
          // The session object from our API contains the user claims
          setUser(session);
        } else {
          // The API returned 401 or another error, no valid session
          setUser(null);
        }
      } catch (error) {
        console.error('Error checking session:', error);
        setUser(null);
      }
      setLoading(false);
    };

    checkSession();
  }, []);

  const login = async (email: string, password: string) => {
    // Call our server endpoint to handle the login
    const res = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });

    if (!res.ok) {
      const errorData = await res.json();
      throw new Error(errorData.message || 'Failed to log in');
    }

    // After a successful login, refetch the session to update the user state
    const sessionRes = await fetch('/api/auth/session');
    if (sessionRes.ok) {
      const { session } = await sessionRes.json();
      setUser(session);
    } else {
      setUser(null);
    }
  };

  const signup = async (email: string, password: string) => {
    // Call our server endpoint to handle the signup
    const res = await fetch('/api/auth/signup', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });

    if (!res.ok) {
      const errorData = await res.json();
      throw new Error(errorData.message || 'Failed to sign up');
    }
    // After signup, the user must log in separately.
  };

  const logout = async () => {
    // Tell the server to clear the session cookie
    await fetch('/api/auth/logout', { method: 'POST' });
    // Immediately clear the user state on the client
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, logout, signup }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
