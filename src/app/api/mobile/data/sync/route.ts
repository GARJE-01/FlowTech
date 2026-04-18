
import { db } from "@/db";
import { shops, products, productVariants, orders, orderItems, notifications, payments } from "@/db/schema";
import { eq, and, gte, ne, count, inArray, desc, sql } from "drizzle-orm";
import { NextResponse } from "next/server";

export async function GET(req: Request) {
    try {
        const { searchParams } = new URL(req.url);
        const salesmanId = searchParams.get("salesmanId");

        if (!salesmanId) {
            return NextResponse.json({ error: "Salesman ID is required" }, { status: 400 });
        }

        // 1. Fetch All Active Shops
        const allShops = await db.select().from(shops).where(eq(shops.isActive, true));

        // 2. Fetch All Products with Variants
        const allProducts = await db.select().from(products);
        const allVariants = await db.select().from(productVariants);

        const productsWithVariants = allProducts.map(p => ({
            ...p,
            variants: allVariants.filter(v => v.productId === p.id)
        }));

        // 3. Fetch Salesman's Recent Orders
        const salesmanOrders = await db.select()
            .from(orders)
            .where(eq(orders.salesmanId, salesmanId))
            .orderBy(desc(orders.createdAt))
            .limit(50);
            
        const orderIds = salesmanOrders.map(o => o.id);
        let allOrderItems: any[] = [];
        
        if (orderIds.length > 0) {
            allOrderItems = await db.select().from(orderItems).where(inArray(orderItems.orderId, orderIds));
        }

        const ordersWithItems = salesmanOrders.map(o => ({
            ...o,
            items: allOrderItems.filter(i => i.orderId === o.id)
        }));

        // 4. Calculate Salesman Dashboard Stats
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const todayOrders = await db.select({ count: count() })
            .from(orders)
            .where(and(eq(orders.salesmanId, salesmanId), gte(orders.createdAt, today)));

        const pendingPayments = await db.select({ 
            total: sql<string>`SUM(${orders.totalAmount} - ${orders.paidAmount})` 
        })
            .from(orders)
            .where(and(
                eq(orders.salesmanId, salesmanId),
                eq(orders.isPaid, false),
                ne(orders.status, 'rejected')
            ));

        // 5. Fetch Salesman Notifications
        const userNotifications = await db.select()
            .from(notifications)
            .where(eq(notifications.salesmanId, salesmanId))
            .orderBy(desc(notifications.createdAt))
            .limit(50);

        // 6. Fetch Salesman Payments History
        const userPayments = await db.select()
            .from(payments)
            .where(eq(payments.salesmanId, salesmanId))
            .orderBy(desc(payments.createdAt));

        return NextResponse.json({
            success: true,
            data: {
                shops: allShops,
                products: productsWithVariants,
                orders: ordersWithItems,
                notifications: userNotifications,
                payments: userPayments,
                stats: {
                    todayOrders: todayOrders[0]?.count || 0,
                    pendingPayments: Number(pendingPayments[0]?.total || 0)
                }
            }
        });

    } catch (error) {
        console.error("Mobile sync route error:", error);
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}
