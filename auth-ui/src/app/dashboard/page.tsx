import DashboardPageClient from "./DashboardPageClient";
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'MouthMetrics Dashboard',
  description: 'Manage your dental practice with ease.',
};

export default function DashboardPage() {
  return <DashboardPageClient />;
}
