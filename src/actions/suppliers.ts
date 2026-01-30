
"use server"

import { db } from "@/db";
import { suppliers } from "@/db/schema";
import { revalidatePath } from "next/cache";
import { sql } from "drizzle-orm";

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

export async function updateSupplier(id: number, data: {
    name: string;
    contactPerson?: string;
    email?: string;
    phone?: string;
    address?: string;
}) {
    try {
        await db.update(suppliers).set(data).where(sql`${suppliers.id} = ${id}`);
        revalidatePath("/admin/suppliers");
        return { success: true };
    } catch (error) {
        console.error("Failed to update supplier:", error);
        return { success: false, error: "Failed to update supplier" };
    }
}


export async function importSuppliersFromCSV(data: any[]) {
    try {
        // data should be array of objects matching supplier fields
        // We'll filter valid ones
        console.log("CSV Import - Received Data (First Item):", data[0]);
        console.log("CSV Import - Keys of first item:", data[0] ? Object.keys(data[0]) : "No data");

        const validData = data.map(item => {
            // Helper to normalize keys (strip BOM, non-alphanumeric, lowercase)
            const normalizeKey = (key: string) => key.replace(/[^a-zA-Z0-9]/g, '').toLowerCase();

            const getValue = (targetKeys: string[]) => {
                const itemKeys = Object.keys(item);
                const normalizedTargetKeys = targetKeys.map(k => normalizeKey(k));

                for (let i = 0; i < normalizedTargetKeys.length; i++) {
                    const target = normalizedTargetKeys[i];
                    // Find key in item that normalizes to the target
                    const foundKey = itemKeys.find(k => normalizeKey(k) === target);
                    if (foundKey && item[foundKey]) return item[foundKey];
                }
                return undefined;
            };

            // Handle Phone: convert scientific notation to string if needed
            let phone = getValue(['phone', 'phonenumber', 'mobile', 'cell']);
            if (typeof phone === 'number') {
                phone = phone.toLocaleString('fullwide', { useGrouping: false });
            }

            return {
                name: getValue(['name', 'suppliername', 'company', 'businessname']),
                contactPerson: getValue(['contactperson', 'contact', 'person', 'contactpe']),
                email: getValue(['email', 'emailaddress']),
                phone: phone ? String(phone) : undefined
            };
        }).filter(item => item.name); // Name is required

        if (validData.length === 0) {
            const firstItemKeys = data[0] ? Object.keys(data[0]).join(", ") : "Empty Data";
            return {
                success: false,
                error: `No valid data found. Found columns: [${firstItemKeys}]. Expected 'Name' column.`
            };
        }

        await db.insert(suppliers).values(validData);
        revalidatePath("/admin/suppliers");
        return { success: true, count: validData.length };
    } catch (error) {
        console.error("Failed to import suppliers:", error);
        return { success: false, error: "Failed to import suppliers: " + (error as Error).message };
    }
}
