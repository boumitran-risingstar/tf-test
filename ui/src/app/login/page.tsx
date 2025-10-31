import LoginPageClient from "./LoginPageClient";
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Login - MouthMetrics',
  description: 'Login to your MouthMetrics account.',
};

export default function LoginPage() {
  return <LoginPageClient />;
}
