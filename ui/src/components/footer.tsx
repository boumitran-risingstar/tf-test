'use client';

import Link from 'next/link';

export function Footer() {
  return (
    <footer className="flex flex-col gap-2 sm:flex-row py-6 w-full shrink-0 items-center px-4 md:px-6 border-t bg-muted text-muted-foreground">
      <p className="text-xs">&copy; 2025 MouthMetrics. All rights reserved.</p>
      <nav className="sm:ml-auto flex gap-4 sm:gap-6">
        <Link href="/privacy" className="text-xs hover:underline underline-offset-4">
          Privacy Policy
        </Link>
        <Link href="/terms" className="text-xs hover:underline underline-offset-4">
          Terms & Conditions
        </Link>
      </nav>
    </footer>
  );
}
