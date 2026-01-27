
"use client"

import { Button } from "@/components/ui/button";
import { approveOrder, rejectOrder } from "@/actions/orders";
import { useState } from "react";
import { Check, X, FileText, Loader2 } from "lucide-react";
import { authClient } from "@/lib/auth-client";
import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";

interface OrderActionsProps {
    orderId: string;
    status: string;
    items: any[];
    totalAmount: number;
}

export function OrderActions({ orderId, status, items, totalAmount }: OrderActionsProps) {
    const [loading, setLoading] = useState(false);
    const session = authClient.useSession();

    const handleApprove = async () => {
        if (!session.data?.user?.id) return;
        setLoading(true);
        await approveOrder(orderId, session.data.user.id);
        setLoading(false);
    };

    const handleReject = async () => {
        if (!session.data?.user?.id) return;
        setLoading(true);
        await rejectOrder(orderId, session.data.user.id);
        setLoading(false);
    };

    const generateInvoice = () => {
        const doc = new jsPDF();

        doc.setFontSize(20);
        doc.text("INVOICE", 14, 22);

        doc.setFontSize(11);
        doc.text(`Order ID: ${orderId}`, 14, 30);
        doc.text(`Date: ${new Date().toLocaleDateString()}`, 14, 35);

        // @ts-ignore
        autoTable(doc, {
            head: [['Product', 'SKU', 'Quantity', 'Price', 'Total']],
            body: items.map(item => [
                item.productName,
                item.sku,
                item.quantity,
                `$${item.price}`,
                `$${(item.quantity * item.price).toFixed(2)}`
            ]),
            startY: 40,
        });

        // @ts-ignore
        const finalY = doc.lastAutoTable.finalY + 10;
        doc.text(`Total Amount: $${totalAmount.toFixed(2)}`, 14, finalY);

        doc.save(`invoice-${orderId}.pdf`);
    };

    return (
        <div className="flex gap-2">
            {(status === 'pending') && (
                <>
                    <Button variant="default" className="bg-green-600 hover:bg-green-700" onClick={handleApprove} disabled={loading}>
                        {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Check className="mr-2 h-4 w-4" />}
                        Approve
                    </Button>
                    <Button variant="destructive" onClick={handleReject} disabled={loading}>
                        {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <X className="mr-2 h-4 w-4" />}
                        Reject
                    </Button>
                </>
            )}
            {status === 'approved' && (
                <Button variant="outline" onClick={generateInvoice}>
                    <FileText className="mr-2 h-4 w-4" /> Download Invoice
                </Button>
            )}
        </div>
    )
}
