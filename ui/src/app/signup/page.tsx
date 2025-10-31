import SignupPageClient from "./SignupPageClient";
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Sign Up - MouthMetrics',
  description: 'Create a new MouthMetrics account.',
};

export default function SignupPage() {
  return <SignupPageClient />;
}
