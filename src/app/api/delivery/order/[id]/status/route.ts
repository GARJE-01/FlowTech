
import { db } from "@/db";
import { orders } from "@/db/schema";
import { eq } from "drizzle-orm";
import { NextResponse } from "next/server";
import { revalidatePath } from "next/cache";

export async function PATCH(req: Request, { params }: { params: Promise<{ id: string }> }) {
    try {
        const { id } = await params;
        const body = await req.json();
        const { status } = body;

        if (!status || !['delivered', 'cancelled'].includes(status)) {
            return NextResponse.json({ error: "Invalid status" }, { status: 400 });
        }

        await db.update(orders)
            .set({ status: status, updatedAt: new Date() })
            .where(eq(orders.id, id));

        revalidatePath("/admin/orders");

        return NextResponse.json({ success: true });
    } catch (error) {
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}
