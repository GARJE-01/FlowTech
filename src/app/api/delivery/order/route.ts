
import { createOrder } from "@/actions/orders";
import { NextResponse } from "next/server";

export async function POST(req: Request) {
    try {
        const body = await req.json();
        // body: { items: [{ variantId, quantity, price }], salesmanId }

        if (!body.items || !Array.isArray(body.items)) {
            return NextResponse.json({ error: "Invalid items" }, { status: 400 });
        }

        if (!body.shopId) {
            return NextResponse.json({ error: "Missing shopId" }, { status: 400 });
        }

        const res = await createOrder({
            items: body.items,
            salesmanId: body.salesmanId, // Optional, or use a delivery-specific ID
            shopId: body.shopId
        });

        if (res.success) {
            return NextResponse.json({ success: true, orderId: res.orderId });
        } else {
            return NextResponse.json({ error: res.error }, { status: 500 });
        }
    } catch (error) {
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}
