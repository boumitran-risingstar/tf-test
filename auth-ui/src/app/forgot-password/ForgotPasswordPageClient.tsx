'use client';
import { useState } from "react";
import { Button } from "@/components/button";
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from "@/components/card";
import Link from "next/link";
import { auth } from "@/firebase/config";
import { sendPasswordResetEmail } from "firebase/auth";

export default function ForgotPasswordPageClient() {
  const [email, setEmail] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(false);
    try {
      await sendPasswordResetEmail(auth, email);
      setSuccess(true);
    } catch (error: any) {
      setError(error.message);
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-muted">
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle>Forgot Password</CardTitle>
          <CardDescription>Enter your email to reset your password.</CardDescription>
        </CardHeader>
        <CardContent>
          {success ? (
            <p className="text-green-500">A password reset email has been sent to your email address.</p>
          ) : (
            <form onSubmit={handleResetPassword} className="space-y-4">
              <div className="space-y-2">
                <label htmlFor="email" className="text-sm font-medium">Email</label>
                <input id="email" type="email" placeholder="m@example.com" required className="w-full px-3 py-2 border rounded-md" value={email} onChange={(e) => setEmail(e.target.value)} />
              </div>
              {error && <p className="text-red-500 text-sm">{error}</p>}
              <Button type="submit" className="w-full">Reset Password</Button>
            </form>
          )}
        </CardContent>
        <CardFooter className="flex justify-center">
          <p className="text-sm text-muted-foreground">
            Remember your password?{" "}
            <Link href="/login" className="font-semibold text-primary">
              Sign In
            </Link>
          </p>
        </CardFooter>
      </Card>
    </div>
  );
}