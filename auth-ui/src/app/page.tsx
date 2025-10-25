import { Button } from "@/components/button";
import { Card, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/card";
import { ScrollAnimation } from "@/components/scroll-animation";

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
        <ScrollAnimation>
          <section className="py-12 md:py-24 lg:py-32">
            <div className="container mx-auto px-4 md:px-6 text-center space-y-4">
              <h1 className="text-4xl md:text-6xl font-bold tracking-tighter text-foreground">The All-in-One Hub for Your Dental Practice</h1>
              <p className="max-w-3xl mx-auto text-lg md:text-xl text-muted-foreground">From payroll and scheduling to content creation and social media, MouthMetrics unifies your entire practice.</p>
              <div className="flex justify-center">
                <Button size="lg">Request a Demo</Button>
              </div>
            </div>
          </section>
        </ScrollAnimation>
        <ScrollAnimation delay={0.15}>
          <section className="py-12 md:py-24 lg:py-32 bg-muted">
            <div className="container mx-auto px-4 md:px-6 grid md:grid-cols-3 gap-8">
              <Card className="bg-background">
                <CardHeader>
                  <CardTitle>Unified Listing & Review Management</CardTitle>
                  <CardDescription>Keep your practice information consistent across Google, Yelp, and Healthgrades. Automatically request patient reviews to build your reputation.</CardDescription>
                </CardHeader>
                <CardFooter>
                  <Button variant="outline">Learn More</Button>
                </CardFooter>
              </Card>
              <Card className="bg-background">
                <CardHeader>
                  <CardTitle>Publish Practice News & Offers</CardTitle>
                  <CardDescription>Announce new staff, share special promotions, and publish articles with our built-in content and review workflow.</CardDescription>
                </CardHeader>
                <CardFooter>
                  <Button variant="outline">Learn More</Button>
                </CardFooter>
              </Card>
              <Card className="bg-background">
                <CardHeader>
                  <CardTitle>Integrated Payroll & HR</CardTitle>
                  <CardDescription>Connect time tracking directly to payroll, manage PTO, and streamline your entire HR process from one central dashboard.</CardDescription>
                </CardHeader>
                <CardFooter>
                  <Button variant="outline">Learn More</Button>
                </CardFooter>
              </Card>
            </div>
          </section>
        </ScrollAnimation>
        <ScrollAnimation delay={0.25}>
          <section className="py-12 md:py-24 lg:py-32">
            <div className="container mx-auto px-4 md:px-6 text-center space-y-8">
              <h2 className="text-3xl md:text-4xl font-bold tracking-tighter">How It Works</h2>
              <div className="grid md:grid-cols-3 gap-8 text-left">
                <div className="space-y-2">
                  <h3 className="text-xl font-semibold">1. Sync Your Data</h3>
                  <p className="text-muted-foreground">Connect your existing systems to MouthMetrics in minutes. Our platform integrates with your PMS, accounting software, and social media accounts.</p>
                </div>
                <div className="space-y-2">
                  <h3 className="text-xl font-semibold">2. Automate & Manage</h3>
                  <p className="text-muted-foreground">Let our AI-powered tools handle the repetitive tasks. From payroll to patient reminders, we've got you covered.</p>
                </div>
                <div className="space-y-2">
                  <h3 className="text-xl font-semibold">3. Grow Your Practice</h3>
                  <p className="text-muted-foreground">Use our insights and publishing tools to attract new patients, create engaging content, and build a thriving practice.</p>
                </div>
              </div>
            </div>
          </section>
        </ScrollAnimation>
        <ScrollAnimation delay={0.35}>
          <section className="py-12 md:py-24 lg:py-32 bg-muted">
            <div className="container mx-auto px-4 md:px-6 text-center space-y-8">
              <h2 className="text-3xl md:text-4xl font-bold tracking-tighter">What Our Customers Say</h2>
              <div className="grid md:grid-cols-2 gap-8">
                <Card className="bg-background">
                  <CardHeader>
                    <p className="text-muted-foreground">MouthMetrics has been a game-changer for our practice. We've saved countless hours on administrative tasks, and our online presence has never been stronger.</p>
                    <div className="pt-4">
                      <p className="font-semibold">Dr. Jane Doe</p>
                      <p className="text-sm text-muted-foreground">Sunny Smiles Dental</p>
                    </div>
                  </CardHeader>
                </Card>
                <Card className="bg-background">
                  <CardHeader>
                    <p className="text-muted-foreground">The integrated payroll and HR features are a lifesaver. I can finally manage my team and finances all in one place.</p>
                    <div className="pt-4">
                      <p className="font-semibold">Dr. John Smith</p>
                      <p className="text-sm text-muted-foreground">Brighton Dental</p>
                    </div>
                  </CardHeader>
                </Card>
              </div>
            </div>
          </section>
        </ScrollAnimation>
        <ScrollAnimation delay={0.45}>
          <section className="py-12 md:py-24 lg:py-32">
            <div className="container mx-auto px-4 md:px-6 text-center space-y-4">
              <h2 className="text-3xl md:text-4xl font-bold tracking-tighter">Ready to Grow Your Practice?</h2>
              <p className="max-w-xl mx-auto text-lg text-muted-foreground">Request a demo to see how MouthMetrics can help you streamline your operations, attract new patients, and build a thriving practice.</p>
              <Button size="lg">Request a Demo</Button>
            </div>
          </section>
        </ScrollAnimation>
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
