import HomePageClient from "./HomePageClient";
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'MouthMetrics: The Unified Dental Practice Hub',
  description: 'An all-in-one SaaS solution to streamline operations, manage your team, control finances, and build your online brand from a single, data-driven dashboard.',
};

export default function HomePage() {
  return <HomePageClient />;
}
