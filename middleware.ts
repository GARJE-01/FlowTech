import { betterFetch } from "@better-fetch/fetch";
import type { Session, User } from "better-auth/types";
import { NextResponse, type NextRequest } from "next/server";

export default async function authMiddleware(request: NextRequest) {
    const { data } = await betterFetch<{ session: Session; user: User }>(
        "/api/auth/get-session",
        {
            baseURL: request.nextUrl.origin,
            headers: {
                //get the cookie from the request
                cookie: request.headers.get("cookie") || "",
            },
        },
    );

    if (!data?.session) {
        return NextResponse.redirect(new URL("/login", request.url));
    }

    // Role-Based Access Control
    // If the user is trying to access /admin but they are not an admin, deny access.
    if (request.nextUrl.pathname.startsWith('/admin') && (data.user as any)?.role !== 'admin') {
        return NextResponse.redirect(new URL("/unauthorized", request.url));
    }

    return NextResponse.next();
}

export const config = {
    matcher: ["/admin/:path*"],
};
