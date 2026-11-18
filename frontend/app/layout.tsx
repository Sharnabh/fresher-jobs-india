import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "FirstStep — Fresher jobs and internships in India",
  description: "A focused search for early-career jobs and internships in India.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}
