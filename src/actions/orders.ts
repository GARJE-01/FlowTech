
"use server"

import { db } from "@/db";
import { orders, orderItems, productVariants, stockLedger, shops } from "@/db/schema";
import { revalidatePath } from "next/cache";
import { eq, sql } from "drizzle-orm";
import { createNotification } from "@/lib/notifications";

export async function createOrder(data: {
    items: { variantId: number; quantity: number; price: number }[];
    salesmanId?: string;
    shopId: number;
}) {

    try {
        const totalAmount = data.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);

        // Generate Order ID (simple logic)
        const orderId = `ORD-${new Date().getFullYear()}${Math.floor(Math.random() * 10000).toString().padStart(4, '0')}`;

        await db.transaction(async (tx) => {
            await tx.insert(orders).values({
                id: orderId,
                salesmanId: data.salesmanId,
                shopId: data.shopId,
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

            // Optional: Increase shop balance here if you want to track pending debt
            // For now, let's keep it consistent with "Approved" orders being the official debt.
        });

        revalidatePath("/admin/orders");

        if (data.salesmanId) {
            await createNotification({
                salesmanId: data.salesmanId,
                type: 'order',
                title: 'Order Created',
                message: `Order #${orderId} has been created successfully.`,
                relatedId: orderId
            });
        }

        return { success: true, orderId };
    } catch (error) {
        console.error("Failed to create order:", error);
        return { success: false, error: "Failed to create order" };
    }
}

export async function approveOrder(orderId: string, approverId: string) {
    try {
        await db.transaction(async (tx) => {
            // 1. Get existing order to find salesmanId
            const [orderRecord] = await tx.select().from(orders).where(eq(orders.id, orderId));

            // 2. Update Order Status
            await tx.update(orders)
                .set({ status: "approved", approverId, updatedAt: new Date() })
                .where(eq(orders.id, orderId));

            // 3. Deduct Stock
            const items = await tx.select().from(orderItems).where(eq(orderItems.orderId, orderId));

            for (const item of items) {
                // Update Variant Stock
                await tx.update(productVariants)
                    .set({
                        currentStock: sql`${productVariants.currentStock} - ${item.quantity}`
                    })
                    .where(eq(productVariants.id, item.variantId));

                // Add to Stock Ledger
                await tx.insert(stockLedger).values({
                    variantId: item.variantId,
                    changeAmount: -item.quantity,
                    type: "ORDER",
                    referenceId: orderId,
                    notes: "Order Approved",
                });
            }

            // 4. Increase Shop's Outstanding Balance
            if (orderRecord) {
                await tx.update(shops)
                    .set({
                        outstandingBalance: sql`${shops.outstandingBalance} + ${orderRecord.totalAmount}`
                    })
                    .where(eq(shops.id, orderRecord.shopId));
            }
        });

        revalidatePath("/admin/orders");
        revalidatePath("/admin/inventory");

        // Notify Salesman
        const [orderData] = await db.select({ salesmanId: orders.salesmanId }).from(orders).where(eq(orders.id, orderId));
        if (orderData?.salesmanId) {
            await createNotification({
                salesmanId: orderData.salesmanId,
                type: 'order',
                title: 'Order Approved',
                message: `Your order #${orderId} has been approved.`,
                relatedId: orderId
            });
        }

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

        // Notify Salesman
        const [orderData] = await db.select({ salesmanId: orders.salesmanId }).from(orders).where(eq(orders.id, orderId));
        if (orderData?.salesmanId) {
            await createNotification({
                salesmanId: orderData.salesmanId,
                type: 'order',
                title: 'Order Rejected',
                message: `Your order #${orderId} has been rejected.`,
                relatedId: orderId
            });
        }

        return { success: true };
    } catch (error) {
        return { success: false, error: "Failed to reject order" };
    }
}
