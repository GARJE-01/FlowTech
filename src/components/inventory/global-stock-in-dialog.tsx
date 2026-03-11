"use client"

import { useState, useMemo, useEffect } from "react"
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
import { stockIn } from "@/actions/inventory"
import { ArrowDownToLine, Package } from "lucide-react"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

interface GlobalStockInDialogProps {
    suppliers: { id: number; name: string }[];
    products: { 
        id: number; 
        name: string; 
        variants: { id: number; sku: string; variantName: string | null }[] 
    }[];
    mappings: { supplierId: number; productId: number }[];
}

export function GlobalStockInDialog({ suppliers, products, mappings }: GlobalStockInDialogProps) {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    const [supplierId, setSupplierId] = useState<string>("");
    const [productId, setProductId] = useState<string>("");
    const [variantId, setVariantId] = useState<string>("");
    const [quantity, setQuantity] = useState("");
    const [notes, setNotes] = useState("");

    // Filtered Products based on Supplier
    const filteredProducts = useMemo(() => {
        if (!supplierId) return products;
        const validProductIds = mappings
            .filter(m => m.supplierId === parseInt(supplierId))
            .map(m => m.productId);
        return products.filter(p => validProductIds.includes(p.id));
    }, [supplierId, products, mappings]);

    // Filtered Suppliers based on Product
    const filteredSuppliers = useMemo(() => {
        if (!productId) return suppliers;
        const validSupplierIds = mappings
            .filter(m => m.productId === parseInt(productId))
            .map(m => m.supplierId);
        return suppliers.filter(s => validSupplierIds.includes(s.id));
    }, [productId, suppliers, mappings]);

    // Auto-select supplier if product is chosen and only one supplier exists
    useEffect(() => {
        if (productId && !supplierId) {
            const validSuppliers = mappings.filter(m => m.productId === parseInt(productId));
            if (validSuppliers.length === 1) {
                setSupplierId(validSuppliers[0].supplierId.toString());
            }
        }
    }, [productId, supplierId, mappings]);

    // Variants for selected product
    const productVariants = useMemo(() => {
        if (!productId) return [];
        return products.find(p => p.id === parseInt(productId))?.variants || [];
    }, [productId, products]);

    const handleSubmit = async () => {
        if (!variantId || !quantity) return;
        setLoading(true);
        try {
            const res = await stockIn({
                variantId: parseInt(variantId),
                quantity: parseInt(quantity),
                supplierId: supplierId ? parseInt(supplierId) : undefined,
                notes
            });
            if (res.success) {
                setOpen(false);
                resetForm();
            } else {
                alert(res.error || "Failed to add stock");
            }
        } catch (e) {
            alert("Failed to add stock");
        } finally {
            setLoading(false);
        }
    };

    const resetForm = () => {
        setSupplierId("");
        setProductId("");
        setVariantId("");
        setQuantity("");
        setNotes("");
    };

    return (
        <Dialog open={open} onOpenChange={(val) => { setOpen(val); if(!val) resetForm(); }}>
            <DialogTrigger asChild>
                <Button variant="default"><ArrowDownToLine className="mr-2 h-4 w-4" /> Global Stock In</Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>Stock In</DialogTitle>
                    <DialogDescription>
                        Centralized stock-in management. Select supplier and product to add inventory.
                    </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                    {/* Supplier Selection */}
                    <div className="grid gap-2">
                        <Label>Supplier</Label>
                        <Select value={supplierId} onValueChange={setSupplierId}>
                            <SelectTrigger>
                                <SelectValue placeholder="Select Supplier (Optional)" />
                            </SelectTrigger>
                            <SelectContent>
                                {filteredSuppliers.map(s => (
                                    <SelectItem key={s.id} value={s.id.toString()}>{s.name}</SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>

                    {/* Product Selection */}
                    <div className="grid gap-2">
                        <Label>Product</Label>
                        <Select value={productId} onValueChange={(val) => { setProductId(val); setVariantId(""); }}>
                            <SelectTrigger>
                                <SelectValue placeholder="Select Product" />
                            </SelectTrigger>
                            <SelectContent>
                                {filteredProducts.map(p => (
                                    <SelectItem key={p.id} value={p.id.toString()}>{p.name}</SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>

                    {/* Variant Selection */}
                    {productVariants.length > 0 && (
                        <div className="grid gap-2">
                            <Label>Variant / SKU</Label>
                            <Select value={variantId} onValueChange={setVariantId}>
                                <SelectTrigger>
                                    <SelectValue placeholder="Select SKU" />
                                </SelectTrigger>
                                <SelectContent>
                                    {productVariants.map(v => (
                                        <SelectItem key={v.id} value={v.id.toString()}>
                                            {v.sku} {v.variantName ? `(${v.variantName})` : ""}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>
                    )}

                    <div className="grid gap-2">
                        <Label>Quantity</Label>
                        <Input type="number" value={quantity} onChange={(e) => setQuantity(e.target.value)} placeholder="0" />
                    </div>

                    <div className="grid gap-2">
                        <Label>Notes</Label>
                        <Input value={notes} onChange={(e) => setNotes(e.target.value)} placeholder="Optional notes (e.g. PO#)" />
                    </div>
                </div>
                <DialogFooter>
                    <Button onClick={handleSubmit} disabled={loading || !variantId || !quantity}>
                        {loading ? "Adding..." : "Confirm Stock In"}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
