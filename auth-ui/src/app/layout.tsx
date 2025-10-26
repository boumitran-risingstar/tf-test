'use client';
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { Toaster } from 'react-hot-toast';
import { ParallaxProvider } from 'react-scroll-parallax';

const inter = Inter({ subsets: ["latin"] });

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <ParallaxProvider>
          <Toaster position="top-center" />
          {children}
        </ParallaxProvider>
      </body>
    </html>
  );
}
