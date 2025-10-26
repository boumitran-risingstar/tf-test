'use client';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/card";
import { Briefcase, ClipboardList, BarChart3, PenSquare } from "lucide-react";
import Link from "next/link";
import Image from 'next/image';
import { useEffect, useState } from 'react';
import { auth } from "@/firebase/config";
import { useRouter } from 'next/navigation';
import { Loader } from "@/components/loader";
import { Parallax, ParallaxProvider } from 'react-scroll-parallax';

export default function HomePage() {
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged(user => {
      if (user) {
        router.push('/dashboard');
      } else {
        setLoading(false);
      }
    });

    return () => unsubscribe();
  }, [router]);

  return (
    <ParallaxProvider>
      <div className="bg-background text-foreground">
        <main className="flex-1">
        <Parallax y={[-20, 20]} tag="section">
        <section className="w-full py-12 md:py-24 lg:py-32 xl:py-48">
          <div className="container px-4 md:px-6">
            <div className="grid gap-6 lg:grid-cols-[1fr_400px] lg:gap-12 xl:grid-cols-[1fr_600px]">
              <div className="flex flex-col justify-center space-y-4">
                <div className="space-y-2">
                  <h1 className="text-3xl font-bold tracking-tighter sm:text-5xl xl:text-6xl/none">
                    MouthMetrics: The Unified Dental Practice Hub
                  </h1>
                  <p className="max-w-[600px] text-muted-foreground md:text-xl">
                    An all-in-one SaaS solution to streamline operations, manage your team, control finances, and build your online brand from a single, data-driven dashboard.
                  </p>
                </div>
                <div className="flex flex-col gap-2 min-[400px]:flex-row">
                  <Link
                    href="/login"
                    className="inline-flex h-10 items-center justify-center rounded-md bg-accent text-accent-foreground px-8 text-sm font-medium shadow transition-colors hover:bg-accent/90 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50"
                  >
                    {loading ? <Loader /> : 'Get Started'}
                  </Link>
                </div>
              </div>
              <Parallax speed={-10}>
              <div className="h-auto w-full max-w-md mx-auto">
                  <Image
                    src="/hero.svg"
                    width="550"
                    height="500"
                    alt="Dental practice connection illustration"
                    className="mx-auto overflow-hidden rounded-xl object-contain h-auto w-full"
                    priority
                  />
              </div>
              </Parallax>
            </div>
          </div>
        </section>
        </Parallax>
        <Parallax y={[-20, 20]} tag="section">
        <section className="w-full py-12 md:py-24 lg:py-32 bg-muted border-t">
          <div className="container px-4 md:px-6">
            <div className="flex flex-col items-center justify-center space-y-4 text-center">
              <div className="space-y-2">
                <div className="inline-block rounded-lg bg-accent text-accent-foreground px-3 py-1 text-sm">
                  Key Modules
                </div>
                <h2 className="text-3xl font-bold tracking-tighter sm:text-5xl">Solve Fragmentation & High Overhead</h2>
                <p className="max-w-[900px] text-muted-foreground md:text-xl/relaxed lg:text-base/relaxed xl:text-xl/relaxed">
                  Dental practices are burdened by administrative fragmentation using 6+ systems. MouthMetrics integrates everything you need, saving time and reducing errors.
                </p>
              </div>
            </div>
            <div className="mx-auto grid max-w-5xl items-center gap-6 py-12 lg:grid-cols-2 lg:gap-12">
              <div className="grid gap-4">
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center">
                      <ClipboardList className="w-5 h-5 mr-2" />
                      Workflow & Billing
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-muted-foreground">
                      Cloud-based scheduling, HIPAA/PCI compliant invoicing, and integrated payroll management to streamline your core operations.
                    </p>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center">
                      <BarChart3 className="w-5 h-5 mr-2" />
                      Metrics & Reputation
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-muted-foreground">
                      Automatically sync business listings, manage patient reviews, and publish practice news or special offers with a dedicated tool.
                    </p>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center">
                      <PenSquare className="w-5 h-5 mr-2" />
                      Content & Social Hub
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-muted-foreground">
                      Use our AI Content Generator and internal review workflow to create and publish authoritative dental articles and social media posts.
                    </p>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center">
                      <Briefcase className="w-5 h-5 mr-2" />
                      Job & Talent Board
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-muted-foreground">
                      Find, track, and manage dental-specific roles with our integrated job board and applicant tracking system.
                    </p>
                  </CardContent>
                </Card>
              </div>
              <Parallax speed={-10}>
                  <Image
                    src="/key-modules.svg"
                    width="550"
                    height="310"
                    alt="Metrics report illustration"
                    className="mx-auto overflow-hidden rounded-xl object-contain h-auto w-full lg:order-last"
                  />
                </Parallax>
            </div>
          </div>
        </section>
        </Parallax>
      </main>
      </div>
    </ParallaxProvider>
  );
}
