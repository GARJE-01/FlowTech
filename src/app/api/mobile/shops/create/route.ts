import { db } from "@/db";
import { shops } from "@/db/schema";
import { NextResponse } from "next/server";
import { createNotification } from "@/actions/notifications";

export async function POST(req: Request) {
    try {
        const body = await req.json();

        // Basic validation
        if (!body.shopName || !body.ownerName || !body.city || !body.mobileNumber || !body.address) {
            return NextResponse.json({ error: "Missing required fields" }, { status: 400 });
        }

        // Insert new shop into the database
        const newShop = await db.insert(shops).values({
            shopName: body.shopName,
            ownerName: body.ownerName,
            city: body.city,
            mobileNumber: body.mobileNumber,
            address: body.address,
            gstNumber: body.gstNumber || null,
            isActive: body.isActive ?? true,
        }).returning({
            id: shops.id, // Get the generated integer ID
        });

        if (newShop.length > 0) {
            if (body.salesmanId) {
                await createNotification({
                    salesmanId: body.salesmanId,
                    type: 'shop',
                    title: 'Shop Added',
                    message: `Shop '${body.shopName}' has been added successfully.`,
                    relatedId: newShop[0].id.toString()
                });
            }

            return NextResponse.json({
                success: true,
                shopId: newShop[0].id, // Send back the real database ID
            });
        } else {
            return NextResponse.json({ error: "Failed to insert shop" }, { status: 500 });
        }

    } catch (error) {
        console.error("Mobile shop creation error:", error);
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}
