
"use server"

import { db } from "@/db";
import { user } from "@/db/schema";
import { revalidatePath } from "next/cache";
import { eq } from "drizzle-orm";
import { auth } from "@/lib/auth"; // We use auth.api to create users properly with hashing

export async function addSalesman(data: {
    name: string;
    email: string;
    password: string;
}) {
    try {
        // Use better-auth API to create user with hashing
        await auth.api.signUpEmail({
            body: {
                email: data.email,
                password: data.password,
                name: data.name,
                role: "salesman"
            }
        });

        revalidatePath("/admin/salesmen");
        return { success: true };
    } catch (error) {
        console.error("Failed to add salesman:", error);
        return { success: false, error: "Failed to add salesman (Email might exist)" };
    }
}

export async function deleteUser(userId: string) {
    try {
        await db.delete(user).where(eq(user.id, userId));
        revalidatePath("/admin/salesmen");
        return { success: true };
    } catch (error) {
        console.error("Failed to delete user:", error);
        return { success: false, error: "Failed to delete user" };
    }
}
