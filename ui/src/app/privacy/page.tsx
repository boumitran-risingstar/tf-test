import { Card, CardContent, CardHeader, CardTitle } from "@/components/card";
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Privacy Policy - MouthMetrics',
  description: 'Read the MouthMetrics privacy policy.',
};

export default function PrivacyPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <Card>
        <CardHeader>
          <CardTitle>Privacy Policy</CardTitle>
        </CardHeader>
        <CardContent className="prose max-w-none">
          <h2>1. Introduction</h2>
          <p>
            Welcome to MouthMetrics. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about our policy, or our practices with regards to your personal information, please contact us.
          </p>

          <h2>2. Information We Collect</h2>
          <p>
            We collect personal information that you voluntarily provide to us when you register on the app, express an interest in obtaining information about us or our products and services, when you participate in activities on the app or otherwise when you contact us.
          </p>

          <h2>3. How We Use Your Information</h2>
          <p>
            We use personal information collected via our app for a variety of business purposes described below. We process your personal information for these purposes in reliance on our legitimate business interests, in order to enter into or perform a contract with you, with your consent, and/or for compliance with our legal obligations.
          </p>

          <h2>4. Will Your Information Be Shared With Anyone?</h2>
          <p>
            We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations.
          </p>

          <h2>5. How Long Do We Keep Your Information?</h2>
          <p>
            We keep your information for as long as necessary to fulfill the purposes outlined in this privacy policy unless otherwise required by law.
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
