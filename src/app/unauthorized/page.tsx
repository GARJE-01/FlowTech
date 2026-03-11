import { ShieldAlert } from "lucide-react";
import Link from "next/link";
import { Button } from "@/components/ui/button";

export default function UnauthorizedPage() {
    return (
        <div className="flex flex-col items-center justify-center min-h-screen p-4 text-center">
            <ShieldAlert className="w-24 h-24 text-red-500 mb-6" />
            <h1 className="text-4xl font-bold mb-2">Access Denied</h1>
            <p className="text-lg text-muted-foreground mb-8 max-w-md">
                You do not have permission to view the Admin Dashboard. This area is restricted to administrators only.
            </p>
            <div className="flex gap-4">
                <Button asChild variant="outline">
                    <Link href="/">Back to Home</Link>
                </Button>
                <Button asChild>
                    <Link href="/login">Sign In with Different Account</Link>
                </Button>
            </div>
        </div>
    );
}
