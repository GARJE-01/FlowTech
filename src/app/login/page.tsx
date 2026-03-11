
"use client";

import { authClient } from "@/lib/auth-client"; // import the auth client
import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Loader2 } from "lucide-react";

export default function SignIn() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [loading, setLoading] = useState(false);
    const router = useRouter();

    const signIn = async () => {
        setLoading(true);
        const { data, error } = await authClient.signIn.email({
            email,
            password,
        }, {
            onRequest: () => {
                // show loading
            },
            onSuccess: async (ctx) => {
                // Instantly check role
                const sessionResponse = await authClient.getSession();
                const role = (sessionResponse.data?.user as any)?.role;

                if (role !== 'admin') {
                    // Sign them completely out so they don't even get a session
                    await authClient.signOut();
                    alert("Access Denied: You must be an administrator to log into this dashboard. Salesmen must use the Mobile App.");
                    setLoading(false);
                    return;
                }

                router.push("/admin");
            },
            onError: (ctx) => {
                alert(ctx.error.message);
                setLoading(false);
            },
        });
    };

    return (
        <div className="flex items-center justify-center min-h-screen bg-gray-100 dark:bg-gray-900">
            <Card className="w-full max-w-md">
                <CardHeader>
                    <CardTitle>Sign In</CardTitle>
                    <CardDescription>
                        Enter your email below to login to your account
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="grid gap-4">
                        <div className="grid gap-2">
                            <Label htmlFor="email">Email</Label>
                            <Input
                                id="email"
                                type="email"
                                placeholder="m@example.com"
                                required
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                            />
                        </div>
                        <div className="grid gap-2">
                            <Label htmlFor="password">Password</Label>
                            <Input
                                id="password"
                                type="password"
                                required
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                            />
                        </div>
                        <Button onClick={signIn} className="w-full" disabled={loading}>
                            {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
                            Sign In
                        </Button>
                    </div>
                </CardContent>
                <CardFooter className="flex justify-center text-sm text-gray-500">
                    <p>Contact your admin if you don't have an account.</p>
                </CardFooter>
            </Card>
        </div>
    );
}
