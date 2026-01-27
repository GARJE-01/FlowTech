
"use client"

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { createOrder } from "@/actions/orders";
import { Plus, Trash, Loader2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { authClient } from "@/lib/auth-client";

interface VariantOption {
    id: number;
    name: string;
    price: number;
    stock: number;
}

export function CreateOrderForm({ variants }: { variants: VariantOption[] }) {
    const [items, setItems] = useState<{ variantId: string; quantity: number; price: number }[]>([]);
    const [loading, setLoading] = useState(false);
    const router = useRouter();
    const session = authClient.useSession();

    const addItem = () => {
        setItems([...items, { variantId: "", quantity: 1, price: 0 }]);
    };

    const removeItem = (index: number) => {
        setItems(items.filter((_, i) => i !== index));
    };

    const updateItem = (index: number, field: string, value: any) => {
        const newItems = [...items];
        // @ts-ignore
        newItems[index][field] = value;

        if (field === 'variantId') {
            const variant = variants.find(v => v.id.toString() === value);
            if (variant) {
                newItems[index].price = variant.price;
            }
        }
        setItems(newItems);
    };

    const totalAmount = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);

    const handleSubmit = async () => {
        if (items.length === 0) return alert("Add at least one item");
        if (items.some(i => !i.variantId || i.quantity <= 0)) return alert("Invalid items");

        setLoading(true);
        try {
            const res = await createOrder({
                items: items.map(i => ({
                    variantId: parseInt(i.variantId),
                    quantity: i.quantity,
                    price: i.price
                })),
                salesmanId: session.data?.user?.id
            });

            if (res.success) {
                router.push("/admin/orders");
            } else {
                alert("Failed: " + res.error);
            }
        } catch (error) {
            alert("Error creating order");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Card>
            <CardContent className="p-6 space-y-4">
                {items.map((item, index) => (
                    <div key={index} className="flex gap-4 items-end border-b pb-4">
                        <div className="flex-1">
                            <Label>Product / SKU</Label>
                            <Select value={item.variantId} onValueChange={(val) => updateItem(index, 'variantId', val)}>
                                <SelectTrigger>
                                    <SelectValue placeholder="Select Product" />
                                </SelectTrigger>
                                <SelectContent>
                                    {variants.map(v => (
                                        <SelectItem key={v.id} value={v.id.toString()}>
                                            {v.name} (Stock: {v.stock}) - ₹{v.price}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>
                        <div className="w-24">
                            <Label>Qty</Label>
                            <Input
                                type="number"
                                min="1"
                                value={item.quantity}
                                onChange={(e) => updateItem(index, 'quantity', parseInt(e.target.value))}
                            />
                        </div>
                        <div className="w-32">
                            <Label>Price (Unit)</Label>
                            <Input
                                type="number"
                                readOnly
                                value={item.price}
                                className="bg-muted"
                            />
                        </div>
                        <div className="w-32">
                            <Label>Total</Label>
                            <div className="h-10 flex items-center font-bold">
                                ₹{(item.price * item.quantity).toFixed(2)}
                            </div>
                        </div>
                        <Button variant="ghost" size="icon" className="text-red-500" onClick={() => removeItem(index)}>
                            <Trash className="h-4 w-4" />
                        </Button>
                    </div>
                ))}

                <Button variant="outline" onClick={addItem} className="w-full">
                    <Plus className="mr-2 h-4 w-4" /> Add Item
                </Button>

                <div className="flex justify-between items-center pt-4 border-t">
                    <div className="text-xl font-bold">
                        Grand Total: ₹{totalAmount.toFixed(2)}
                    </div>
                    <Button size="lg" onClick={handleSubmit} disabled={loading}>
                        {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
                        Create Order
                    </Button>
                </div>
            </CardContent>
        </Card>
    )
}
