'use client';
import { Button } from "@/components/button";
import { Input } from "@/components/input";
import { Label } from "@/components/label";
import Link from "next/link";
import { useState, FormEvent } from 'react';
import toast from 'react-hot-toast';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useAuth } from '@/context/AuthContext';

export default function LoginPageClient() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const router = useRouter();
  const { login } = useAuth();

  const handleLogin = async (e: FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      toast.error("Please enter both email and password.");
      return;
    }

    try {
      await login(email, password);
      router.push('/dashboard');
    } catch (error: any) {
      toast.error(error.message || 'Failed to log in. Please try again.');
    }
  };


  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="w-full max-w-md p-8 space-y-8 bg-white rounded-lg shadow-md dark:bg-gray-800">
        <div className="flex justify-center">
            <Image
                src="/hero.svg"
                alt="Your Company Logo"
                width={150} 
                height={150}
            />
        </div>
        <h2 className="text-2xl font-bold text-center text-gray-900 dark:text-white">Welcome Back!</h2>
        <p className="text-center text-gray-600 dark:text-gray-300">Sign in to continue to your dashboard</p>
        <form className="space-y-6" onSubmit={handleLogin}>
          <div>
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              name="email"
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <div>
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              name="password"
              type="password"
              autoComplete="current-password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <div className="flex items-center justify-between">
            <div className="text-sm">
              <Link href="/forgot-password">
                <span className="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400 dark:hover:text-primary-300">Forgot your password?</span>
              </Link>
            </div>
            <div className="text-sm">
              <Link href="/phone-signin">
                <span className="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400 dark:hover:text-primary-300">Sign in with phone</span>
              </Link>
            </div>
          </div>
          <Button type="submit" className="w-full">Log In</Button>
        </form>
        <p className="text-sm text-center text-gray-600 dark:text-gray-300">
          Don't have an account? <Link href="/signup"><span className="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400 dark:hover:text-primary-300">Sign up</span></Link>
        </p>
      </div>
    </div>
  );
}
