
"use server"

import { db } from "@/db";
import { orders, orderItems, productVariants, stockLedger } from "@/db/schema";
import { revalidatePath } from "next/cache";
import { eq, sql } from "drizzle-orm";
import { auth } from "@/lib/auth"; // Access session if needed server-side, but usually passed or context

export async function createOrder(data: {
    items: { variantId: number; quantity: number; price: number }[];
    salesmanId?: string; // If null, maybe admin created it
}) {
    try {
        const totalAmount = data.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);

        // Generate Order ID (simple logic)
        const orderId = `ORD-${new Date().getFullYear()}${Math.floor(Math.random() * 10000).toString().padStart(4, '0')}`;

        await db.transaction(async (tx) => {
            await tx.insert(orders).values({
                id: orderId,
                salesmanId: data.salesmanId,
                totalAmount: totalAmount,
                status: "pending",
            });

            for (const item of data.items) {
                await tx.insert(orderItems).values({
                    orderId: orderId,
                    variantId: item.variantId,
                    quantity: item.quantity,
                    price: item.price,
                });
            }
        });

        revalidatePath("/admin/orders");
        return { success: true, orderId };
    } catch (error) {
        console.error("Failed to create order:", error);
        return { success: false, error: "Failed to create order" };
    }
}

export async function approveOrder(orderId: string, approverId: string) {
    try {
        await db.transaction(async (tx) => {
            // 1. Update Order Status
            await tx.update(orders)
                .set({ status: "approved", approverId, updatedAt: new Date() })
                .where(eq(orders.id, orderId));

            // 2. Deduct Stock
            const items = await tx.select().from(orderItems).where(eq(orderItems.orderId, orderId));

            for (const item of items) {
                // Check stock first? Assuming forced deduction or check in UI.

                // Update Variant Stock
                await tx.update(productVariants)
                    .set({
                        currentStock: sql`${productVariants.currentStock} - ${item.quantity}`
                    })
                    .where(eq(productVariants.id, item.variantId));

                // Add to Stock Ledger
                await tx.insert(stockLedger).values({
                    variantId: item.variantId,
                    changeAmount: -item.quantity, // Negative for OUT
                    type: "ORDER",
                    referenceId: orderId,
                    notes: "Order Approved",
                });
            }
        });

        revalidatePath("/admin/orders");
        revalidatePath("/admin/inventory");
        return { success: true };
    } catch (error) {
        console.error("Failed to approve order:", error);
        return { success: false, error: "Failed to approve order" };
    }
}

export async function rejectOrder(orderId: string, approverId: string) {
    try {
        await db.update(orders)
            .set({ status: "rejected", approverId, updatedAt: new Date() })
            .where(eq(orders.id, orderId));

        revalidatePath("/admin/orders");
        return { success: true };
    } catch (error) {
        return { success: false, error: "Failed to reject order" };
    }
}
