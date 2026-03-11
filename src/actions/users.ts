
"use server"

import { db } from "@/db";
import { user } from "@/db/schema";
import { revalidatePath } from "next/cache";
import { eq } from "drizzle-orm";
import { auth } from "@/lib/auth"; // We use auth.api to create users properly with hashing
import { createNotification } from "./notifications";

export async function addSalesman(data: {
    name: string;
    email: string;
    password: string;
    phoneNumber: string;
    area: string;
}) {
    try {
        // Use better-auth API to create user with hashing
        const signUpResult = await auth.api.signUpEmail({
            body: {
                email: data.email,
                password: data.password,
                name: data.name,
                role: "salesman"
            }
        });

        // signUpEmail doesn't support custom fields directly in the body for the user table easily without hooks
        // So we update the user record manually after creation
        if (signUpResult.user) {
            await db.update(user)
                .set({ 
                    phoneNumber: data.phoneNumber,
                    area: data.area 
                })
                .where(eq(user.id, signUpResult.user.id));

            // Generate Welcome Notification
            await createNotification({
                salesmanId: signUpResult.user.id,
                type: 'system',
                title: 'Welcome to FlowTech!',
                message: 'Your account has been set up successfully.',
            });
        }

        revalidatePath("/admin/salesmen");
        return { success: true };
    } catch (error: any) {
        console.error("DEBUG: Failed to add salesman. Full error:", error);
        // Extract specific error message if possible
        const errorMessage = error?.message || "Unknown error";
        return { success: false, error: `Failed to create user: ${errorMessage}` };
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
