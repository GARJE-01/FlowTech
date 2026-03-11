"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Trash2, Loader2 } from "lucide-react";
import { deleteUser } from "@/actions/users";
import { useRouter } from "next/navigation";

interface DeleteSalesmanButtonProps {
    userId: string;
    userName: string;
    disabled?: boolean;
}

export function DeleteSalesmanButton({ userId, userName, disabled }: DeleteSalesmanButtonProps) {
    const [isDeleting, setIsDeleting] = useState(false);
    const router = useRouter();

    const handleDelete = async () => {
        if (!confirm(`Are you sure you want to delete ${userName}? This action cannot be undone.`)) {
            return;
        }

        setIsDeleting(true);
        try {
            const result = await deleteUser(userId);
            if (!result.success) {
                alert(result.error);
            } else {
                router.refresh(); // Refresh the page to show updated list
            }
        } catch (error) {
            console.error("Error deleting user:", error);
            alert("An unexpected error occurred.");
        } finally {
            setIsDeleting(false);
        }
    };

    return (
        <Button 
            variant="destructive" 
            size="sm" 
            onClick={handleDelete}
            disabled={isDeleting || disabled}
            title={disabled ? "Cannot delete administrators" : "Delete user"}
        >
            {isDeleting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Trash2 className="h-4 w-4" />}
        </Button>
    );
}
