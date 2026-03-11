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
import { Textarea } from "@/components/ui/textarea"
import { addShop } from "@/actions/shops"
import { Plus } from "lucide-react"

export function AddShopDialog() {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    const [shopName, setShopName] = useState("");
    const [ownerName, setOwnerName] = useState("");
    const [city, setCity] = useState("");
    const [mobileNumber, setMobileNumber] = useState("");
    const [gstNumber, setGstNumber] = useState("");
    const [address, setAddress] = useState("");

    const handleSubmit = async () => {
        if (!shopName || !ownerName || !city || !mobileNumber || !address) {
            alert("Please fill in all required fields.");
            return;
        }

        setLoading(true);
        try {
            const res = await addShop({
                shopName,
                ownerName,
                city,
                mobileNumber,
                gstNumber: gstNumber || undefined,
                address
            });
            if (res.success) {
                setOpen(false);
                setShopName("");
                setOwnerName("");
                setCity("");
                setMobileNumber("");
                setGstNumber("");
                setAddress("");
            } else {
                alert(res.error);
            }
        } catch (e) {
            alert("Failed to add shop");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button><Plus className="mr-2 h-4 w-4" /> Add Shop</Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>Add New Shop</DialogTitle>
                    <DialogDescription>
                        Enter shop details below. All fields except GST Number are required.
                    </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                    <div className="grid gap-2">
                        <Label htmlFor="shopName">Shop Name</Label>
                        <Input id="shopName" value={shopName} onChange={(e) => setShopName(e.target.value)} placeholder="e.g. Agarwal Stores" />
                    </div>
                    <div className="grid gap-2">
                        <Label htmlFor="ownerName">Owner Name</Label>
                        <Input id="ownerName" value={ownerName} onChange={(e) => setOwnerName(e.target.value)} placeholder="Owner's Full Name" />
                    </div>
                    <div className="grid gap-2">
                        <Label htmlFor="mobileNumber">Mobile Number</Label>
                        <Input id="mobileNumber" value={mobileNumber} onChange={(e) => setMobileNumber(e.target.value)} placeholder="10-digit mobile number" />
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                        <div className="grid gap-2">
                            <Label htmlFor="city">City</Label>
                            <Input id="city" value={city} onChange={(e) => setCity(e.target.value)} placeholder="City" />
                        </div>
                        <div className="grid gap-2">
                            <Label htmlFor="gstNumber">GST Number (Optional)</Label>
                            <Input id="gstNumber" value={gstNumber} onChange={(e) => setGstNumber(e.target.value)} placeholder="GSTIN" />
                        </div>
                    </div>
                    <div className="grid gap-2">
                        <Label htmlFor="address">Full Address</Label>
                        <Textarea id="address" value={address} onChange={(e) => setAddress(e.target.value)} placeholder="Shop Street Address" />
                    </div>
                </div>
                <DialogFooter>
                    <Button onClick={handleSubmit} disabled={loading}>
                        {loading ? "Adding..." : "Add Shop"}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
