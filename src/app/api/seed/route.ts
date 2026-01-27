
import { auth } from "@/lib/auth";
import { NextResponse } from "next/server";

export async function GET() {
    try {
        // Check if admin exists logic could be added here, but for now we just try to create.
        // Better-auth might throw if email exists.

        // Create Admin
        const adminUser = await auth.api.signUpEmail({
            body: {
                email: "admin@agency.com",
                password: "password123",
                name: "System Administrator",
                role: "admin", // Need to make sure 'role' is passed correctly based on schema
            },
        });

        // Create Salesman
        const salesmanUser = await auth.api.signUpEmail({
            body: {
                email: "salesman@agency.com",
                password: "password123",
                name: "Sales Representative",
                role: "salesman",
            },
        });

        return NextResponse.json({
            message: "Seeding complete",
            admin: "admin@agency.com / password123",
            salesman: "salesman@agency.com / password123"
        });
    } catch (error) {
        return NextResponse.json({ error: "Seeding failed or users already exist", details: String(error) }, { status: 500 });
    }
}
