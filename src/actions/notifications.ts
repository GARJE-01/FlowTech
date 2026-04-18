"use server";

import { revalidatePath } from "next/cache";
import { createNotification as createNotificationInternal } from "@/lib/notifications";

export async function createNotification(data: {
  salesmanId: string;
  type: string;
  title: string;
  message: string;
  relatedId?: string;
}) {
  const result = await createNotificationInternal(data);
  if (result.success) {
    revalidatePath("/admin");
  }
  return result;
}
