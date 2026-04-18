export const dynamic = "force-dynamic";

import { getProductsWithVariants, getSuppliersSelect, getSupplierProductMappings } from "@/db/queries";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCaption, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Plus, Archive } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import Link from "next/link";
import { AddProductDialog } from "@/components/inventory/add-product-dialog";
import { GlobalStockInDialog } from "@/components/inventory/global-stock-in-dialog";
import { ProductCSVImport } from "@/components/inventory/product-csv-import";

export default async function InventoryPage() {
    const products = await getProductsWithVariants();
    const suppliers = await getSuppliersSelect();
    const mappings = await getSupplierProductMappings();

    return (
        <div className="flex flex-col gap-4">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold tracking-tight">Inventory</h1>
                <div className="flex gap-2">
                    <ProductCSVImport />
                    <GlobalStockInDialog 
                        suppliers={suppliers} 
                        products={products} 
                        mappings={mappings} 
                    />
                    <AddProductDialog />
                </div>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Product Catalog</CardTitle>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Product Name</TableHead>
                                <TableHead>Category</TableHead>
                                <TableHead>Base Price</TableHead>
                                <TableHead>Variants</TableHead>
                                <TableHead className="text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {products.map((product) => (
                                <TableRow key={product.id}>
                                    <TableCell className="font-medium">
                                        {product.name}
                                        {product.description && <p className="text-xs text-muted-foreground">{product.description}</p>}
                                    </TableCell>
                                    <TableCell>{product.category}</TableCell>
                                    <TableCell>₹{product.basePrice.toFixed(2)}</TableCell>
                                    <TableCell>
                                        <div className="flex flex-col gap-2">
                                            {product.variants.map(v => (
                                                <div key={v.id} className="flex items-center justify-between border p-2 rounded-md text-sm">
                                                    <div>
                                                        <span className="font-semibold">{v.sku}</span>
                                                        {v.variantName && <span className="text-muted-foreground"> ({v.variantName})</span>}
                                                        <div className="text-xs">Stock: {v.currentStock} | Price: ₹{v.price}</div>
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    </TableCell>
                                    <TableCell className="text-right">
                                        <AddProductDialog
                                            initialData={{
                                                id: product.id,
                                                name: product.name,
                                                category: product.category,
                                                basePrice: product.basePrice,
                                                variants: product.variants.map(v => ({
                                                    id: v.id,
                                                    sku: v.sku,
                                                    price: v.price,
                                                    currentStock: v.currentStock,
                                                    variantName: v.variantName
                                                }))
                                            }}
                                            trigger={<Button variant="ghost" size="sm">Edit</Button>}
                                        />
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </CardContent>
            </Card>
        </div>
    );
}
