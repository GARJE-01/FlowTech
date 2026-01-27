
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
import { addSalesman } from "@/actions/users"
import { Plus } from "lucide-react"

export function AddSalesmanDialog() {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    const [name, setName] = useState("");
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");

    const handleSubmit = async () => {
        setLoading(true);
        try {
            const res = await addSalesman({
                name,
                email,
                password
            });
            if (res.success) {
                setOpen(false);
                setName("");
                setEmail("");
                setPassword("");
            } else {
                alert(res.error);
            }

        } catch (e) {
            alert("Failed to add salesman");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button><Plus className="mr-2 h-4 w-4" /> Add User</Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>Add New Salesman</DialogTitle>
                    <DialogDescription>
                        Create a new account for a salesman.
                    </DialogDescription>
                </DialogHeader>
                <div className="grid gap-4 py-4">
                    <div className="grid gap-2">
                        <Label>Name</Label>
                        <Input value={name} onChange={(e) => setName(e.target.value)} placeholder="Full Name" />
                    </div>
                    <div className="grid gap-2">
                        <Label>Email</Label>
                        <Input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="email@agency.com" />
                    </div>
                    <div className="grid gap-2">
                        <Label>Password</Label>
                        <Input type="password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="******" />
                    </div>
                </div>
                <DialogFooter>
                    <Button onClick={handleSubmit} disabled={loading}>
                        {loading ? "Creating..." : "Create Account"}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}
