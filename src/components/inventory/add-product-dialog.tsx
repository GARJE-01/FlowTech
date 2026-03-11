
"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { addProduct, updateProduct } from "@/actions/inventory"
import { Plus, Trash, Edit } from "lucide-react"
import { Card, CardContent } from "@/components/ui/card"

interface AddProductDialogProps {
    initialData?: {
        id: number;
        name: string;
        category: string;
        basePrice: number;
        variants: {
            id: number;
            sku: string;
            price: number;
            currentStock: number;
            variantName: string | null;
        }[];
    };
    trigger?: React.ReactNode;
}

export function AddProductDialog({ initialData, trigger }: AddProductDialogProps) {
    const isEdit = !!initialData;
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    const [name, setName] = useState(initialData?.name || "");
    const [category, setCategory] = useState(initialData?.category || "");
    const [basePrice, setBasePrice] = useState(initialData?.basePrice.toString() || "");

    const [variants, setVariants] = useState(
        initialData?.variants.map(v => ({
            id: v.id,
            sku: v.sku,
            price: v.price.toString(),
            currentStock: v.currentStock.toString(),
            variantName: v.variantName || ""
        })) || [
            { sku: "", price: "", currentStock: "0", variantName: "Default" }
        ]
    );

    const addVariant = () => {
        setVariants([...variants, { sku: "", price: basePrice, currentStock: "0", variantName: "" }]);
    };

    const removeVariant = (index: number) => {
        setVariants(variants.filter((_, i) => i !== index));
    };

    const updateVariant = (index: number, field: string, value: string) => {
        const newVariants = [...variants];
        // @ts-ignore
        newVariants[index][field] = value;
        setVariants(newVariants);
    };

    const handleSubmit = async () => {
        setLoading(true);
        try {
            if (isEdit && initialData) {
                await updateProduct({
                    id: initialData.id,
                    name,
                    category,
                    basePrice: parseFloat(basePrice) || 0,
                    variants: variants.map(v => ({
                        // @ts-ignore
                        id: v.id,
                        sku: v.sku,
                        price: parseFloat(v.price) || 0,
                        currentStock: parseInt(v.currentStock) || 0,
                        variantName: v.variantName
                    }))
                });
            } else {
                await addProduct({
                    name,
                    category,
                    basePrice: parseFloat(basePrice) || 0,
                    variants: variants.map(v => ({
                        sku: v.sku,
                        price: parseFloat(v.price) || 0,
                        initialStock: parseInt(v.currentStock) || 0,
                        variantName: v.variantName
                    }))
                });
            }
            setOpen(false);
            if (!isEdit) {
                // Reset form only if adding
                setName("");
                setCategory("");
                setBasePrice("");
                setVariants([{ sku: "", price: "", currentStock: "0", variantName: "Default" }]);
            }
        } catch (e) {
            alert(isEdit ? "Failed to update product" : "Failed to add product");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                {trigger || <Button><Plus className="mr-2 h-4 w-4" /> Add Product</Button>}
            </DialogTrigger>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>{isEdit ? "Edit Product" : "Add New Product"}</DialogTitle>
                    <DialogDescription>
                        {isEdit ? "Update product details and variants." : "Create a new product with multiple variants (SKUs)."}
                    </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                    <div className="grid grid-cols-2 gap-4">
                        <div className="grid gap-2">
                            <Label>Product Name</Label>
                            <Input value={name} onChange={(e) => setName(e.target.value)} placeholder="e.g. Wireless Mouse" />
                        </div>
                        <div className="grid gap-2">
                            <Label>Category</Label>
                            <Input value={category} onChange={(e) => setCategory(e.target.value)} placeholder="e.g. Electronics" />
                        </div>
                    </div>
                    <div className="grid gap-2">
                        <Label>Base Price (₹)</Label>
                        <Input type="number" value={basePrice} onChange={(e) => setBasePrice(e.target.value)} placeholder="0.00" />
                    </div>

                    <div className="space-y-4">
                        <div className="flex justify-between items-center">
                            <Label>Variants (SKUs)</Label>
                            <Button type="button" variant="outline" size="sm" onClick={addVariant}>Add Variant</Button>
                        </div>
                        {variants.map((variant, index) => (
                            <Card key={index}>
                                <CardContent className="p-4 grid gap-4">
                                    <div className="grid grid-cols-2 gap-2">
                                        <Input placeholder="Variant Name (e.g. Red)" value={variant.variantName} onChange={(e) => updateVariant(index, 'variantName', e.target.value)} />
                                        <Input placeholder="SKU" value={variant.sku} onChange={(e) => updateVariant(index, 'sku', e.target.value)} />
                                    </div>
                                    <div className="grid grid-cols-3 gap-2 items-end">
                                        <div>
                                            <Label className="text-xs">Price</Label>
                                            <Input type="number" placeholder="Price" value={variant.price} onChange={(e) => updateVariant(index, 'price', e.target.value)} />
                                        </div>
                                        <div>
                                            <Label className="text-xs">{isEdit ? "Current Stock" : "Initial Stock"}</Label>
                                            <Input type="number" placeholder="0" value={variant.currentStock} onChange={(e) => updateVariant(index, 'currentStock', e.target.value)} />
                                        </div>
                                        <Button variant="ghost" size="icon" className="text-red-500" onClick={() => removeVariant(index)}>
                                            <Trash className="h-4 w-4" />
                                        </Button>
                                    </div>
                                </CardContent>
                            </Card>
                        ))}
                    </div>

                </div>
                <DialogFooter>
                    <Button onClick={handleSubmit} disabled={loading}>
                        {loading ? "Saving..." : "Save Product"}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
