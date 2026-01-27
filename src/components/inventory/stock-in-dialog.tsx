
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
import { stockIn } from "@/actions/inventory"
import { ArrowDownToLine } from "lucide-react"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

interface StockInDialogProps {
    variantId: number;
    sku: string;
    productName: string;
    suppliers: { id: number; name: string }[];
}

export function StockInDialog({ variantId, sku, productName, suppliers }: StockInDialogProps) {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    const [quantity, setQuantity] = useState("");
    const [supplierId, setSupplierId] = useState("");
    const [notes, setNotes] = useState("");

    const handleSubmit = async () => {
        setLoading(true);
        try {
            await stockIn({
                variantId,
                quantity: parseInt(quantity),
                supplierId: supplierId ? parseInt(supplierId) : undefined,
                notes
            });
            setOpen(false);
            setQuantity("");
            setSupplierId("");
            setNotes("");
        } catch (e) {
            alert("Failed to add stock");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button variant="outline" size="sm"><ArrowDownToLine className="mr-2 h-4 w-4" /> Stock In</Button>
            </DialogTrigger>
            <DialogContent>
                <DialogHeader>
                    <DialogTitle>Stock In: {productName}</DialogTitle>
                    <DialogDescription>
                        Add stock for SKU: {sku}
                    </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                    <div className="grid gap-2">
                        <Label>Quantity</Label>
                        <Input type="number" value={quantity} onChange={(e) => setQuantity(e.target.value)} placeholder="0" />
                    </div>
                    <div className="grid gap-2">
                        <Label>Supplier</Label>
                        <Select value={supplierId} onValueChange={setSupplierId}>
                            <SelectTrigger>
                                <SelectValue placeholder="Select Supplier" />
                            </SelectTrigger>
                            <SelectContent>
                                {suppliers.map(s => (
                                    <SelectItem key={s.id} value={s.id.toString()}>{s.name}</SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>
                    <div className="grid gap-2">
                        <Label>Notes</Label>
                        <Input value={notes} onChange={(e) => setNotes(e.target.value)} placeholder="Optional notes (e.g. PO#123)" />
                    </div>
                </div>
                <DialogFooter>
                    <Button onClick={handleSubmit} disabled={loading}>
                        {loading ? "Adding..." : "Confirm Stock In"}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
