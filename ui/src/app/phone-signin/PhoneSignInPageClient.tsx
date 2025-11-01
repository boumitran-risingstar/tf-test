"use client";
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { appCheck } from '@/firebase/config';
import { getToken } from 'firebase/app-check';
import { useAuth } from '@/context/AuthContext';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/card";
import { Button } from "@/components/button";
import { Input } from "@/components/input";
import { Label } from "@/components/label";
import { Loader } from '@/components/loader';

export default function PhoneSignInPageClient() {
  const router = useRouter();
  const { checkSession, loading: authLoading } = useAuth();
  const [phoneNumber, setPhoneNumber] = useState('');
  const [verificationCode, setVerificationCode] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [sessionInfo, setSessionInfo] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handlePhoneNumberChange = (e: React.ChangeEvent<HTMLInputElement>) => setPhoneNumber(e.target.value);
  const handleVerificationCodeChange = (e: React.ChangeEvent<HTMLInputElement>) => setVerificationCode(e.target.value);

  const handleSendCode = async () => {
    setError(null);
    if (!phoneNumber || !appCheck) return;
    setIsLoading(true);
    try {
      const appCheckToken = await getToken(appCheck, false);
      const response = await fetch('/api/auth/phone-send-code', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-Firebase-AppCheck': appCheckToken.token },
        body: JSON.stringify({ phoneNumber }),
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Unknown error');
      setSessionInfo(data.sessionInfo);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyCode = async () => {
    setError(null);
    if (!verificationCode || !sessionInfo || !appCheck) return;
    setIsLoading(true);
    try {
      const appCheckToken = await getToken(appCheck, false); // This line was missing

      const response = await fetch('/api/auth/phone-verify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-Firebase-AppCheck': appCheckToken.token },
        body: JSON.stringify({ sessionInfo, code: verificationCode }),
      });

      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.error || 'Unknown error');
      }
      
      const user = await checkSession();

      if (user) {
        router.push('/dashboard');
      } else {
        setError('Login succeeded but failed to retrieve user session.');
        setIsLoading(false);
      }
    } catch (err: any) {
      setError(err.message);
      setIsLoading(false);
    }
  };

  if (isLoading || authLoading) {
    return <Loader />;
  }

  return (
    <div className="flex items-center justify-center min-h-screen bg-ray-100 dark:bg-ray-900">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>Phone Sign-in</CardTitle>
          <CardDescription>
            {sessionInfo ? "Enter the code sent to your phone." : "Enter your phone number to receive a verification code."}
          </CardDescription>
        </CardHeader>
        <CardContent>
          {error && <p className="mb-4 text-red-500">{error}</p>}
          {!sessionInfo ? (
            <div className="space-y-4">
              <Label htmlFor="phone-number">Phone Number</Label>
              <Input id="phone-number" type="tel" placeholder="+1 555-555-5555" value={phoneNumber} onChange={handlePhoneNumberChange} />
            </div>
          ) : (
            <div className="space-y-2">
              <Label htmlFor="verification-code">Verification Code</Label>
              <Input id="verification-code" type="text" placeholder="Enter the 6-digit code" value={verificationCode} onChange={handleVerificationCodeChange} />
            </div>
          )}
        </CardContent>
        <CardFooter>
          {!sessionInfo ? (
            <Button onClick={handleSendCode} className="w-full" disabled={isLoading}>{isLoading ? 'Sending...' : 'Send Code'}</Button>
          ) : (
            <Button onClick={handleVerifyCode} className="w-full" disabled={isLoading}>{isLoading ? 'Verifying...' : 'Verify Code'}</Button>
          )}
        </CardFooter>
      </Card>
    </div>
  );
}
