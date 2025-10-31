'use client';
import { Button } from "@/components/button";
import { Input } from "@/components/input";
import { Label } from "@/components/label";
import Link from "next/link";
import { useState, FormEvent } from 'react';
import toast from 'react-hot-toast';
import Image from 'next/image';

export default function ForgotPasswordPageClient() {
  const [email, setEmail] = useState('');

  const handleForgotPassword = async (e: FormEvent) => {
    e.preventDefault();
    if (!email) {
      toast.error("Please enter your email address.");
      return;
    }

    try {
      const response = await fetch('/api/auth/forgot-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to send password reset email.');
      }

      toast.success("A password reset link has been sent to your email.");
    } catch (error: any) {
      toast.error(error.message);
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
        <h2 className="text-2xl font-bold text-center text-gray-900 dark:text-white">Forgot Your Password?</h2>
        <p className="text-center text-gray-600 dark:text-gray-300">No worries, we'll send you a reset link.</p>
        <form className="space-y-6" onSubmit={handleForgotPassword}>
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
          <Button type="submit" className="w-full">Send Reset Link</Button>
        </form>
        <p className="text-sm text-center text-gray-600 dark:text-gray-300">
          Remember your password? <Link href="/login"><span className="font-medium text-primary-600 hover:text-primary-500 dark:text-primary-400 dark:hover:text-primary-300">Log in</span></Link>
        </p>
      </div>
    </div>
  );
}
