import { Button } from "@/components/button";
import { Card, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/card";

export default function Page() {
  return (
    <div className="flex flex-col min-h-screen bg-background">
      <header className="sticky top-0 z-50 w-full border-b bg-secondary text-secondary-foreground backdrop-blur-sm">
        <div className="container flex h-16 items-center justify-between">
          <div className="flex items-center gap-6">
            <a href="#" className="flex items-center gap-2">
              <MountainIcon className="h-6 w-6" />
              <span className="text-lg font-semibold">MouthMetrics</span>
            </a>
            <nav className="hidden md:flex items-center gap-6">
              <a href="#" className="text-sm font-medium text-secondary-foreground/80 transition-colors hover:text-secondary-foreground">Features</a>
              <a href="#" className="text-sm font-medium text-secondary-foreground/80 transition-colors hover:text-secondary-foreground">Pricing</a>
              <a href="#" className="text-sm font-medium text-secondary-foreground/80 transition-colors hover:text-secondary-foreground">Contact</a>
            </nav>
          </div>
          <Button>Get Started</Button>
        </div>
      </header>
      <main className="flex-1">
        <section className="py-12 md:py-24 lg:py-32">
          <div className="container mx-auto px-4 md:px-6 text-center space-y-4">
            <h1 className="text-4xl md:text-6xl font-bold tracking-tighter text-foreground">AI-Powered Dental Analytics</h1>
            <p className="max-w-3xl mx-auto text-lg md:text-xl text-muted-foreground">Understand patient needs, optimize treatments, and grow your practice with our advanced AI platform.</p>
            <div className="flex justify-center">
              <Button size="lg">Request a Demo</Button>
            </div>
          </div>
        </section>
        <section className="py-12 md:py-24 lg:py-32 bg-muted">
          <div className="container mx-auto px-4 md:px-6 grid md:grid-cols-3 gap-8">
            <Card className="bg-background">
              <CardHeader>
                <CardTitle>Patient Insights</CardTitle>
                <CardDescription>Gain a deeper understanding of your patient demographics, needs, and treatment histories.</CardDescription>
              </CardHeader>
              <CardFooter>
                <Button variant="outline">Learn More</Button>
              </CardFooter>
            </Card>
            <Card className="bg-background">
              <CardHeader>
                <CardTitle>Treatment Planning</CardTitle>
                <CardDescription>Leverage AI to create optimized treatment plans that improve patient outcomes.</CardDescription>
              </CardHeader>
              <CardFooter>
                <Button variant="outline">Learn More</Button>
              </CardFooter>
            </Card>
            <Card className="bg-background">
              <CardHeader>
                <CardTitle>Practice Growth</CardTitle>
                <CardDescription>Identify opportunities to expand your services, attract new patients, and increase revenue.</CardDescription>
              </CardHeader>
              <CardFooter>
                <Button variant="outline">Learn More</Button>
              </CardFooter>
            </Card>
          </div>
        </section>
      </main>
    </div>
  );
}

function MountainIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="m8 3 4 8 5-5 5 15H2L8 3z" />
    </svg>
  );
}
