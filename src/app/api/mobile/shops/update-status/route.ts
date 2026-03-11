import { db } from "@/db";
import { shops } from "@/db/schema";
import { eq } from "drizzle-orm";
import { NextResponse } from "next/server";

export async function POST(req: Request) {
    try {
        const body = await req.json();

        if (!body.shopId || body.isActive === undefined) {
            return NextResponse.json({ error: "Missing required fields (shopId, isActive)" }, { status: 400 });
        }

        const shopIdNum = parseInt(body.shopId.toString(), 10);
        if (isNaN(shopIdNum)) {
             return NextResponse.json({ error: "Invalid shop ID" }, { status: 400 });
        }

        // Update shop status
        await db.update(shops)
            .set({
                isActive: Boolean(body.isActive),
            })
            .where(eq(shops.id, shopIdNum));

        return NextResponse.json({ success: true });

    } catch (error) {
        console.error("Mobile shop update error:", error);
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}
