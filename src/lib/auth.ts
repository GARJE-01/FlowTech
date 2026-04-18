
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { db } from "@/db";
import { user, session, account, verification } from "@/db/schema";

export const auth = betterAuth({
    database: drizzleAdapter(db, {
        provider: "pg", // Changed from sqlite
        schema: { user, session, account, verification },
    }),
    trustedOrigins: [
        "http://localhost:3000",
        "http://localhost:3001",
        // Production URL — set BETTER_AUTH_URL in Vercel environment variables
        ...(process.env.BETTER_AUTH_URL ? [process.env.BETTER_AUTH_URL] : []),
    ],
    emailAndPassword: {
        enabled: true,
    },
    user: {
        additionalFields: {
            role: {
                type: "string",
                required: false,
                defaultValue: "salesman",
            },
            phoneNumber: {
                type: "string",
                required: false,
            },
            area: {
                type: "string",
                required: false,
            },

        },
    },
});
