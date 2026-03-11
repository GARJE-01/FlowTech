
import { auth } from "@/lib/auth";
import { NextResponse } from "next/server";

export async function POST(req: Request) {
    try {
        const body = await req.json();
        const { email, password } = body;

        if (!email || !password) {
            return NextResponse.json({ error: "Email and password are required" }, { status: 400 });
        }

        // Use better-auth internal API to verify credentials
        // Note: better-auth usually sets cookies. For mobile, we might need to return the user data
        // and potentially a session token if better-auth supports it via API.
        try {
            const result = await auth.api.signInEmail({
                body: {
                    email,
                    password,
                }
            });

            // If successful, better-auth returns user and session data
            // We strip sensitive info or just return the necessary user details
            return NextResponse.json({
                success: true,
                user: {
                    id: result.user.id,
                    name: result.user.name,
                    email: result.user.email,
                    role: result.user.role,
                    phoneNumber: result.user.phoneNumber,
                    area: result.user.area,
                },

                // Session info might be needed for subsequent requests if we don't use simple ID based auth
                session: (result as any).session
            });
        } catch (authError: any) {

            console.error("Auth error:", authError);
            return NextResponse.json({ error: "Invalid credentials" }, { status: 401 });
        }

    } catch (error) {
        console.error("Mobile login route error:", error);
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}
