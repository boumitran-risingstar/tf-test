import ForgotPasswordPageClient from "./ForgotPasswordPageClient";
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Forgot Password - MouthMetrics',
  description: 'Reset your MouthMetrics account password.',
};

export default function ForgotPasswordPage() {
  return <ForgotPasswordPageClient />;
}
