
import { createOrder } from "@/actions/orders";
import { NextResponse } from "next/server";

export async function POST(req: Request) {
    try {
        const body = await req.json();
        // Expected body from mobile app:
        // { 
        //   shopId: number, 
        //   salesmanId: string, 
        //   items: [{ variantId: number, quantity: number, price: number }] 
        // }

        if (!body.shopId || !body.items || !Array.isArray(body.items)) {
            return NextResponse.json({ error: "Invalid order data" }, { status: 400 });
        }

        const res = await createOrder({
            shopId: body.shopId,
            items: body.items,
            salesmanId: body.salesmanId
        });

        if (res.success) {
            return NextResponse.json({ 
                success: true, 
                orderId: res.orderId 
            });
        } else {
            return NextResponse.json({ error: res.error }, { status: 500 });
        }

    } catch (error) {
        console.error("Mobile order creation error:", error);
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}
