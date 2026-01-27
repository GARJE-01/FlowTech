
"use server"

import { db } from "@/db";
import { suppliers } from "@/db/schema";
import { revalidatePath } from "next/cache";

export async function addSupplier(data: {
    name: string;
    contactPerson?: string;
    email?: string;
    phone?: string;
    address?: string;
}) {
    try {
        await db.insert(suppliers).values(data);
        revalidatePath("/admin/suppliers");
        return { success: true };
    } catch (error) {
        console.error("Failed to add supplier:", error);
        return { success: false, error: "Failed to add supplier" };
    }
}

export async function importSuppliersFromCSV(data: any[]) {
    try {
        // data should be array of objects matching supplier fields
        // We'll filter valid ones
        const validData = data.map(item => ({
            name: item.name || item.Name || item.supplier_name,
            contactPerson: item.contact_person || item.ContactPerson || item.contact,
            email: item.email || item.Email,
            phone: item.phone || item.Phone,
            address: item.address || item.Address
        })).filter(item => item.name); // Name is required

        if (validData.length === 0) return { success: false, error: "No valid data found" };

        await db.insert(suppliers).values(validData);
        revalidatePath("/admin/suppliers");
        return { success: true, count: validData.length };
    } catch (error) {
        console.error("Failed to import suppliers:", error);
        return { success: false, error: "Failed to import suppliers" };
    }
}
