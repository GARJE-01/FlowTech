"use client"

import { useState, useEffect } from "react"
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
import { addSupplier, updateSupplier } from "@/actions/suppliers"
import { Plus, Pencil } from "lucide-react"

interface Supplier {
    id: number;
    name: string;
    contactPerson: string | null;
    email: string | null;
    phone: string | null;
    address: string | null;
}

interface SupplierDialogProps {
    supplier?: Supplier;
}

export function SupplierDialog({ supplier }: SupplierDialogProps) {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    const [name, setName] = useState("");
    const [contactPerson, setContactPerson] = useState("");
    const [email, setEmail] = useState("");
    const [phone, setPhone] = useState("");

    const isEdit = !!supplier;

    useEffect(() => {
        if (open && supplier) {
            setName(supplier.name);
            setContactPerson(supplier.contactPerson || "");
            setEmail(supplier.email || "");
            setPhone(supplier.phone || "");
        } else if (open && !supplier) {
            // Reset for Add mode
            setName("");
            setContactPerson("");
            setEmail("");
            setPhone("");
        }
    }, [open, supplier]);

    const handleSubmit = async () => {
        setLoading(true);
        try {
            const data = {
                name,
                contactPerson,
                email,
                phone,
            };

            if (isEdit && supplier) {
                await updateSupplier(supplier.id, data);
            } else {
                await addSupplier(data);
            }

            setOpen(false);
            if (!isEdit) {
                setName("");
                setContactPerson("");
                setEmail("");
                setPhone("");
            }
        } catch (e) {
            alert(isEdit ? "Failed to update supplier" : "Failed to add supplier");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                {isEdit ? (
                    <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
                        <Pencil className="h-4 w-4" />
                        <span className="sr-only">Edit</span>
                    </Button>
                ) : (
                    <Button variant="outline"><Plus className="mr-2 h-4 w-4" /> Add Supplier</Button>
                )}
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>{isEdit ? "Edit Supplier" : "Add New Supplier"}</DialogTitle>
                    <DialogDescription>
                        {isEdit ? "Update supplier details here." : "Enter supplier details here."}
                    </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                    <div className="grid gap-2">
                        <Label>Supplier Name</Label>
                        <Input value={name} onChange={(e) => setName(e.target.value)} placeholder="Acme Corp" />
                    </div>
                    <div className="grid gap-2">
                        <Label>Contact Person</Label>
                        <Input value={contactPerson} onChange={(e) => setContactPerson(e.target.value)} placeholder="John Doe" />
                    </div>
                    <div className="grid gap-2">
                        <Label>Email</Label>
                        <Input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="contact@acme.com" />
                    </div>
                    <div className="grid gap-2">
                        <Label>Phone</Label>
                        <Input value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="+1 234..." />
                    </div>
                </div>
                <DialogFooter>
                    <Button onClick={handleSubmit} disabled={loading}>
                        {loading ? "Saving..." : (isEdit ? "Update Supplier" : "Save Supplier")}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
