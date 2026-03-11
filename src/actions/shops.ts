"use server"

import { db } from "@/db";
import { shops } from "@/db/schema";
import { revalidatePath } from "next/cache";
import { eq } from "drizzle-orm";

export async function addShop(data: {
    shopName: string;
    ownerName: string;
    city: string;
    mobileNumber: string;
    gstNumber?: string;
    address: string;
}) {
    try {
        await db.insert(shops).values(data);
        revalidatePath("/admin/shops");
        return { success: true };
    } catch (error) {
        console.error("Failed to add shop:", error);
        return { success: false, error: "Failed to add shop" };
    }
}

export async function deleteShop(id: number) {
    try {
        await db.delete(shops).where(eq(shops.id, id));
        revalidatePath("/admin/shops");
        return { success: true };
    } catch (error) {
        console.error("Failed to delete shop:", error);
        return { success: false, error: "Failed to delete shop" };
    }
}

export async function importShopsFromCSV(data: any[]) {
    try {
        console.log("Shops CSV Import - Received Data (First Item):", data[0]);

        const validData = data.map(item => {
            const normalizeKey = (key: string) => key.replace(/[^a-zA-Z0-9]/g, '').toLowerCase();

            const getValue = (targetKeys: string[]) => {
                const itemKeys = Object.keys(item);
                const normalizedTargetKeys = targetKeys.map(k => normalizeKey(k));

                for (let i = 0; i < normalizedTargetKeys.length; i++) {
                    const target = normalizedTargetKeys[i];
                    const foundKey = itemKeys.find(k => normalizeKey(k) === target);
                    if (foundKey && item[foundKey]) return item[foundKey];
                }
                return undefined;
            };

            return {
                shopName: getValue(['shopname', 'shop', 'name', 'storename']),
                ownerName: getValue(['ownername', 'owner', 'proprietor']),
                city: getValue(['city', 'location', 'town']),
                mobileNumber: getValue(['mobilenumber', 'mobile', 'phone', 'contact']),
                gstNumber: getValue(['gstnumber', 'gst', 'gstin']),
                address: getValue(['address', 'shopaddress', 'fulladdress'])
            };
        }).filter(item => item.shopName && item.ownerName && item.city && item.mobileNumber && item.address);

        if (validData.length === 0) {
            return {
                success: false,
                error: "No valid data found. Ensure your CSV has columns like 'Shop Name', 'Owner Name', 'City', 'Mobile Number', and 'Address'."
            };
        }

        await db.insert(shops).values(validData);
        revalidatePath("/admin/shops");
        return { success: true, count: validData.length };
    } catch (error) {
        console.error("Failed to import shops:", error);
        return { success: false, error: "Failed to import shops: " + (error as Error).message };
    }
}
