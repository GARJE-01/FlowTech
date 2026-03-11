
"use server"

import { db } from "@/db";
import { products, productVariants, stockLedger, suppliers } from "@/db/schema";
import { revalidatePath } from "next/cache";
import { eq, sql } from "drizzle-orm";

export async function addProduct(data: {
    name: string;
    category: string;
    description?: string;
    basePrice: number;
    variants: {
        sku: string;
        price: number;
        initialStock: number;
        variantName: string;
    }[];
}) {
    try {
        const result = await db.insert(products).values({
            name: data.name,
            category: data.category,
            description: data.description,
            basePrice: data.basePrice,
        }).returning({ id: products.id });

        const productId = result[0].id;

        for (const variant of data.variants) {
            const variantResult = await db.insert(productVariants).values({
                productId,
                sku: variant.sku,
                price: variant.price,
                variantName: variant.variantName,
                currentStock: variant.initialStock,
            }).returning({ id: productVariants.id });

            // If initial stock > 0, record in ledger
            if (variant.initialStock > 0) {
                await db.insert(stockLedger).values({
                    variantId: variantResult[0].id,
                    changeAmount: variant.initialStock,
                    type: "STOCK_IN",
                    notes: "Initial Stock",
                });
            }
        }

        revalidatePath("/admin/inventory");
        return { success: true };
    } catch (error) {
        console.error("Failed to add product:", error);
        return { success: false, error: "Failed to add product" };
    }
}

export async function updateProduct(data: {
    id: number;
    name: string;
    category: string;
    description?: string;
    basePrice: number;
    variants: {
        id?: number;
        sku: string;
        price: number;
        currentStock: number;
        variantName: string;
    }[];
}) {
    try {
        // 1. Update Product
        await db.update(products).set({
            name: data.name,
            category: data.category,
            description: data.description,
            basePrice: data.basePrice,
        }).where(eq(products.id, data.id));

        // 2. Handle Variants
        // Delete missing, Update existing, Insert new
        const existingVariants = await db.select().from(productVariants).where(eq(productVariants.productId, data.id));
        const incomingIds = data.variants.map(v => v.id).filter(id => id !== undefined) as number[];

        // Delete missing
        for (const existing of existingVariants) {
            if (!incomingIds.includes(existing.id)) {
                await db.delete(productVariants).where(eq(productVariants.id, existing.id));
            }
        }

        // Update or Insert
        for (const variant of data.variants) {
            if (variant.id) {
                await db.update(productVariants).set({
                    sku: variant.sku,
                    price: variant.price,
                    variantName: variant.variantName,
                    currentStock: variant.currentStock,
                }).where(eq(productVariants.id, variant.id));
            } else {
                const newVariant = await db.insert(productVariants).values({
                    productId: data.id,
                    sku: variant.sku,
                    price: variant.price,
                    variantName: variant.variantName,
                    currentStock: variant.currentStock,
                }).returning({ id: productVariants.id });

                if (variant.currentStock > 0) {
                    await db.insert(stockLedger).values({
                        variantId: newVariant[0].id,
                        changeAmount: variant.currentStock,
                        type: "STOCK_IN",
                        notes: "Initial Stock (via Edit)",
                    });
                }
            }
        }

        revalidatePath("/admin/inventory");
        return { success: true };
    } catch (error) {
        console.error("Failed to update product:", error);
        return { success: false, error: "Failed to update product" };
    }
}

export async function stockIn(data: {
    variantId: number;
    quantity: number;
    supplierId?: number;
    notes?: string;
}) {
    try {
        // Update variant stock using atomic increment
        await db.update(productVariants)
            .set({
                currentStock: sql`${productVariants.currentStock} + ${data.quantity}`
            })
            .where(eq(productVariants.id, data.variantId));

        // Add to ledger
        await db.insert(stockLedger).values({
            variantId: data.variantId,
            changeAmount: data.quantity,
            type: "STOCK_IN",
            supplierId: data.supplierId,
            notes: data.notes || "Stock In",
        });

        revalidatePath("/admin/inventory");
        revalidatePath("/admin/stock-ledger");
        return { success: true };
    } catch (error) {
        console.error("Stock In failed:", error);
        return { success: false, error: "Stock In failed" };
    }
}

export async function importProductsFromCSV(data: any[]) {
    try {
        const validData = data.map(item => ({
            name: item.name || item.Name || item.product_name,
            category: item.category || item.Category,
            description: item.description || item.Description,
            basePrice: parseFloat(item.basePrice || item.BasePrice || item.price || item.Price || "0"),
            sku: item.sku || item.SKU,
            variantName: item.variantName || item.VariantName,
            price: parseFloat(item.price || item.Price || item.selling_price || "0"),
            stock: parseInt(item.stock || item.Stock || item.quantity || item.Quantity || "0"),
        })).filter(item => item.name && item.basePrice && item.sku);

        if (validData.length === 0) return { success: false, error: "No valid data found. Ensure Name, Base Price, and SKU are present." };

        let successCount = 0;
        let errors: string[] = [];

        // We process sequentially to check for existing products/variants more reliably in a loop
        // Optimization: In a real large-scale app, we might bulk fetch existing SKUs first.
        for (const item of validData) {
            try {
                // 1. Find or Create Product
                // Simple heuristic: check if product with same name exists? 
                // For simplicity in this bulk import, let's assume if the exact name exists, we use it, else create.
                // NOTE: Ideally we'd have a product ID in CSV, but typically CSVs are 'flat'.

                let productId: number;

                const existingProduct = await db.query.products.findFirst({
                    where: eq(products.name, item.name)
                });

                if (existingProduct) {
                    productId = existingProduct.id;
                } else {
                    const newProduct = await db.insert(products).values({
                        name: item.name,
                        category: item.category || "Uncategorized",
                        description: item.description,
                        basePrice: item.basePrice,
                    }).returning({ id: products.id });
                    productId = newProduct[0].id;
                }

                // 2. Check if variant exists
                const existingVariant = await db.query.productVariants.findFirst({
                    where: eq(productVariants.sku, item.sku)
                });

                if (existingVariant) {
                    errors.push(`SKU ${item.sku} already exists. Skipping.`);
                    continue;
                }

                // 3. Create Variant
                const newVariant = await db.insert(productVariants).values({
                    productId,
                    sku: item.sku,
                    price: item.price > 0 ? item.price : item.basePrice, // Fallback to base price if variant price not specified
                    variantName: item.variantName,
                    currentStock: item.stock,
                }).returning({ id: productVariants.id });

                // 4. Stock Ledger
                if (item.stock > 0) {
                    await db.insert(stockLedger).values({
                        variantId: newVariant[0].id,
                        changeAmount: item.stock,
                        type: "STOCK_IN",
                        notes: "Initial Import",
                    });
                }

                successCount++;

            } catch (err: any) {
                console.error(`Failed to import item ${item.sku}:`, err);
                errors.push(`Failed to import SKU ${item.sku}: ${err.message}`);
            }
        }

        revalidatePath("/admin/inventory");
        revalidatePath("/admin/stock-ledger");

        return {
            success: true,
            count: successCount,
            errors: errors.length > 0 ? errors : undefined
        };

    } catch (error) {
        console.error("Failed to import products:", error);
        return { success: false, error: "Failed to import products" };
    }
}
