
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
import { addSupplier } from "@/actions/suppliers"
import { Plus } from "lucide-react"

export function AddSupplierDialog() {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    const [name, setName] = useState("");
    const [contactPerson, setContactPerson] = useState("");
    const [email, setEmail] = useState("");
    const [phone, setPhone] = useState("");
    const [address, setAddress] = useState("");

    const handleSubmit = async () => {
        setLoading(true);
        try {
            await addSupplier({
                name,
                contactPerson,
                email,
                phone,
                address,
            });
            setOpen(false);
            // Reset
            setName("");
            setContactPerson("");
            setEmail("");
            setPhone("");
            setAddress("");
        } catch (e) {
            alert("Failed to add supplier");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button variant="outline"><Plus className="mr-2 h-4 w-4" /> Add Supplier</Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>Add New Supplier</DialogTitle>
                    <DialogDescription>
                        Enter supplier details here.
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
                    <div className="grid gap-2">
                        <Label>Address</Label>
                        <Input value={address} onChange={(e) => setAddress(e.target.value)} placeholder="123 Main St..." />
                    </div>
                </div>
                <DialogFooter>
                    <Button onClick={handleSubmit} disabled={loading}>
                        {loading ? "Saving..." : "Save Supplier"}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
