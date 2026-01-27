
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { SquareTerminal } from "lucide-react";

export default function Home() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen gap-6 bg-muted/20">
      <div className="flex flex-col items-center gap-2">
        <div className="p-4 bg-primary rounded-xl">
          <SquareTerminal className="w-12 h-12 text-primary-foreground" />
        </div>
        <h1 className="text-4xl font-bold tracking-tight">Agency System</h1>
        <p className="text-lg text-muted-foreground">Order & Inventory Management Dashboard</p>
      </div>

      <div className="flex gap-4">
        <Button asChild size="lg">
          <Link href="/login">Login</Link>
        </Button>
        <Button asChild variant="outline" size="lg">
          <Link href="/api/seed">Seed Initial Users</Link>
        </Button>
      </div>
    </div>
  );
}
