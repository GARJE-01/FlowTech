"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Trash2, Loader2 } from "lucide-react";
import { deleteShop } from "@/actions/shops";
import { useRouter } from "next/navigation";

interface DeleteShopButtonProps {
    shopId: number;
    shopName: string;
}

export function DeleteShopButton({ shopId, shopName }: DeleteShopButtonProps) {
    const [isDeleting, setIsDeleting] = useState(false);
    const router = useRouter();

    const handleDelete = async () => {
        if (!confirm(`Are you sure you want to delete ${shopName}?`)) {
            return;
        }

        setIsDeleting(true);
        try {
            const result = await deleteShop(shopId);
            if (!result.success) {
                alert(result.error);
            } else {
                router.refresh();
            }
        } catch (error) {
            console.error("Error deleting shop:", error);
            alert("An unexpected error occurred.");
        } finally {
            setIsDeleting(false);
        }
    };

    return (
        <Button 
            variant="ghost" 
            size="icon" 
            onClick={handleDelete}
            disabled={isDeleting}
            className="text-destructive hover:text-destructive hover:bg-destructive/10"
        >
            {isDeleting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Trash2 className="h-4 w-4" />}
        </Button>
    );
}
