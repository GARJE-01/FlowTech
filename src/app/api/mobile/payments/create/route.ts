import { db } from "@/db";
import { payments, orders, shops } from "@/db/schema";
import { eq, sql } from "drizzle-orm";
import { NextResponse } from "next/server";
import { createNotification } from "@/lib/notifications";
import { v4 as uuidv4 } from "uuid";

export async function POST(req: Request) {
    try {
        const body = await req.json();

        // Basic validation
        if (!body.orderId || !body.shopId || !body.salesmanId || body.amount === undefined || !body.paymentMode) {
            return NextResponse.json({ error: "Missing required fields" }, { status: 400 });
        }

        const amountNum = parseFloat(body.amount.toString());
        if (isNaN(amountNum) || amountNum <= 0) {
             return NextResponse.json({ error: "Invalid payment amount" }, { status: 400 });
        }

        const paymentId = uuidv4();

        await db.transaction(async (tx) => {
            // 1. Insert Payment Ledger Entry
            await tx.insert(payments).values({
                id: paymentId,
                orderId: body.orderId,
                shopId: parseInt(body.shopId),
                salesmanId: body.salesmanId,
                amount: amountNum,
                paymentMode: body.paymentMode
            });

            // 2. Update Order's paidAmount and isPaid status
            // First fetch the order to evaluate logic
            const [order] = await tx.select().from(orders).where(eq(orders.id, body.orderId));
            if (!order) throw new Error("Order not found");

            const newPaidAmount = order.paidAmount + amountNum;
            const updatedIsPaid = newPaidAmount >= order.totalAmount;

            await tx.update(orders)
                .set({ 
                    paidAmount: newPaidAmount,
                    isPaid: updatedIsPaid,
                    updatedAt: new Date(),
                })
                .where(eq(orders.id, body.orderId));

            // 3. Decrease Shop's Outstanding Balance
             await tx.update(shops)
                .set({
                    outstandingBalance: sql`${shops.outstandingBalance} - ${amountNum}`
                })
                .where(eq(shops.id, parseInt(body.shopId)));
        });

        // 4. Generate Live Notification
        await createNotification({
            salesmanId: body.salesmanId,
            type: 'payment',
            title: 'Payment Received',
            message: `Received ₹${amountNum.toFixed(2)} towards Order #${body.orderId}.`,
            relatedId: paymentId
        });

        return NextResponse.json({
            success: true,
            paymentId: paymentId,
        });

    } catch (error) {
        console.error("Payment API Error:", error);
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}
