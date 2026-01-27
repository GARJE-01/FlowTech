
import { db } from "@/db";
import { products, productVariants, stockLedger, suppliers, orders, user, orderItems } from "@/db/schema";
import { eq, desc } from "drizzle-orm";

export async function getProductsWithVariants() {
    const allProducts = await db.select().from(products);
    const result = [];

    for (const p of allProducts) {
        const variants = await db.select().from(productVariants).where(eq(productVariants.productId, p.id));
        result.push({
            ...p,
            variants
        });
    }
    return result;
}

export async function getStockLedger() {
    return await db.select({
        id: stockLedger.id,
        date: stockLedger.createdAt,
        type: stockLedger.type,
        changeAmount: stockLedger.changeAmount,
        notes: stockLedger.notes,
        variantSku: productVariants.sku,
        productName: products.name,
        supplierName: suppliers.name
    })
        .from(stockLedger)
        .leftJoin(productVariants, eq(stockLedger.variantId, productVariants.id))
        .leftJoin(products, eq(productVariants.productId, products.id))
        .leftJoin(suppliers, eq(stockLedger.supplierId, suppliers.id))
        .orderBy(desc(stockLedger.createdAt));
}

export async function getSuppliersSelect() {
    return await db.select({ id: suppliers.id, name: suppliers.name }).from(suppliers);
}

export async function getOrders() {
    return await db.select({
        id: orders.id,
        status: orders.status,
        totalAmount: orders.totalAmount,
        createdAt: orders.createdAt,
        salesmanName: user.name
    })
        .from(orders)
        .leftJoin(user, eq(orders.salesmanId, user.id))
        .orderBy(desc(orders.createdAt));
}

export async function getOrder(id: string) {
    const order = await db.select({
        id: orders.id,
        status: orders.status,
        totalAmount: orders.totalAmount,
        createdAt: orders.createdAt,
        salesmanName: user.name
    })
        .from(orders)
        .leftJoin(user, eq(orders.salesmanId, user.id))
        .where(eq(orders.id, id))
        .get();

    if (!order) return null;

    const items = await db.select({
        id: orderItems.id,
        quantity: orderItems.quantity,
        price: orderItems.price,
        sku: productVariants.sku,
        productName: products.name,
        variantName: productVariants.variantName
    })
        .from(orderItems)
        .leftJoin(productVariants, eq(orderItems.variantId, productVariants.id))
        .leftJoin(products, eq(productVariants.productId, products.id))
        .where(eq(orderItems.orderId, id));

    return { ...order, items };
}
