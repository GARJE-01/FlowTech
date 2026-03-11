"use server";

import { db } from "@/db";
import { notifications } from "@/db/schema";
import { v4 as uuidv4 } from "uuid";
import { revalidatePath } from "next/cache";

export async function createNotification(data: {
  salesmanId: string;
  type: string;
  title: string;
  message: string;
  relatedId?: string;
}) {
  try {
    await db.insert(notifications).values({
      id: uuidv4(),
      salesmanId: data.salesmanId,
      type: data.type,
      title: data.title,
      message: data.message,
      relatedId: data.relatedId,
    });
    // Attempt to revalidate mobile sync endpoints isn't strictly necessary as they are dynamic, 
    // but good practice if any dashboard views also show them.
    revalidatePath("/admin");
    return { success: true };
  } catch (error) {
    console.error("Failed to create notification:", error);
    return { success: false, error: "Failed to create notification" };
  }
}
