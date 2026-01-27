
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
import { addProduct } from "@/actions/inventory"
import { Plus, Trash } from "lucide-react"
import { Card, CardContent } from "@/components/ui/card"

export function AddProductDialog() {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    const [name, setName] = useState("");
    const [category, setCategory] = useState("");
    const [basePrice, setBasePrice] = useState("");

    const [variants, setVariants] = useState([
        { sku: "", price: "", initialStock: "0", variantName: "Default" }
    ]);

    const addVariant = () => {
        setVariants([...variants, { sku: "", price: basePrice, initialStock: "0", variantName: "" }]);
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
            await addProduct({
                name,
                category,
                basePrice: parseFloat(basePrice) || 0,
                variants: variants.map(v => ({
                    sku: v.sku,
                    price: parseFloat(v.price) || 0,
                    initialStock: parseInt(v.initialStock) || 0,
                    variantName: v.variantName
                }))
            });
            setOpen(false);
            // Reset form
            setName("");
            setCategory("");
            setBasePrice("");
            setVariants([{ sku: "", price: "", initialStock: "0", variantName: "Default" }]);
        } catch (e) {
            alert("Failed to add product");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button><Plus className="mr-2 h-4 w-4" /> Add Product</Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle>Add New Product</DialogTitle>
                    <DialogDescription>
                        Create a new product with multiple variants (SKUs).
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
                                            <Label className="text-xs">Initial Stock</Label>
                                            <Input type="number" placeholder="0" value={variant.initialStock} onChange={(e) => updateVariant(index, 'initialStock', e.target.value)} />
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
