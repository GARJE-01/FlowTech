export const dynamic = "force-dynamic";

import { getProductsWithVariants, getShops } from "@/db/queries";
import { CreateOrderForm } from "@/components/orders/create-order-form";

export default async function CreateOrderPage() {
    const products = await getProductsWithVariants();
    const shops = await getShops();

    // We need to flatten variants for easier selection
    const flatVariants = products.flatMap(p =>
        p.variants.map(v => ({
            id: v.id,
            name: `${p.name} - ${v.sku} ${v.variantName ? `(${v.variantName})` : ''}`,
            price: v.price,
            stock: v.currentStock
        }))
    );

    return (
        <div className="flex flex-col gap-4">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold tracking-tight">Create New Order</h1>
            </div>
            <CreateOrderForm variants={flatVariants} shops={shops} />
        </div>
    );
}

