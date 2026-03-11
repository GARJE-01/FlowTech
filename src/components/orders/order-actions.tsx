
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
    shopName?: string;
    shopAddress?: string;
    shopGST?: string;
    salesmanName?: string;
    createdAt?: Date;
}

export function OrderActions({ 
    orderId, 
    status, 
    items, 
    totalAmount,
    shopName,
    shopAddress,
    shopGST,
    salesmanName,
    createdAt
}: OrderActionsProps) {
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
        
        // --- Header ---
        doc.setFillColor(235, 248, 255); // blue-50 
        doc.rect(0, 0, 210, 45, 'F');
        
        doc.setFont("helvetica", "bold");
        doc.setFontSize(20);
        doc.setTextColor(37, 99, 235); // primary color
        doc.text("FlowTech Agency", 14, 15);
        
        doc.setFont("helvetica", "normal");
        doc.setFontSize(10);
        doc.setTextColor(0, 0, 0);
        doc.text("123, Industrial Area", 14, 21);
        doc.text("Pune, Maharashtra - 411057", 14, 26);
        doc.text("Ph: +91 98765 43210", 14, 31);
        doc.setFont("helvetica", "bold");
        doc.text("GSTIN: 27AABCT1332L1Z6", 14, 36);
        
        doc.setFont("helvetica", "bold");
        doc.setFontSize(24);
        doc.setTextColor(150, 150, 150);
        doc.text("INVOICE", 196, 20, { align: "right" });
        
        doc.setFontSize(10);
        doc.setTextColor(0, 0, 0);
        doc.text(`# ${orderId}`, 196, 28, { align: "right" });
        doc.setFont("helvetica", "normal");
        const dateStr = createdAt ? new Date(createdAt).toLocaleDateString('en-GB') : new Date().toLocaleDateString('en-GB');
        doc.text(`Date: ${dateStr}`, 196, 33, { align: "right" });
        
        // --- Bill To ---
        doc.setFontSize(9);
        doc.setTextColor(150, 150, 150);
        doc.setFont("helvetica", "bold");
        doc.text("BILL TO:", 14, 55);
        
        doc.setFontSize(12);
        doc.setTextColor(0, 0, 0);
        doc.text(shopName || 'Unknown Shop', 14, 61);
        doc.setFont("helvetica", "normal");
        doc.setFontSize(10);
        doc.text(shopAddress || 'Address not provided', 14, 66);
        if (shopGST) doc.text(`GSTIN: ${shopGST}`, 14, 71);
        
        doc.setFontSize(9);
        doc.setTextColor(150, 150, 150);
        doc.setFont("helvetica", "bold");
        doc.text("DETAILS:", 196, 55, { align: "right" });
        doc.setFont("helvetica", "normal");
        doc.setFontSize(10);
        doc.setTextColor(0, 0, 0);
        doc.text(`Order ID: ...${orderId.slice(-6)}`, 196, 61, { align: "right" });
        doc.text(`Salesman: ${salesmanName || 'Unknown'}`, 196, 66, { align: "right" });
        doc.text("Terms: Credit (7 Days)", 196, 71, { align: "right" });

        // --- Items Table ---
        // @ts-ignore
        autoTable(doc, {
            head: [['ITEM', 'QTY', 'RATE', 'TOTAL']],
            body: items.map(item => {
                const name = `${item.productName} ${item.variantName ? `(${item.variantName})` : ''}`;
                return [
                    name,
                    item.quantity.toString(),
                    `INR ${item.price.toFixed(2)}`,
                    `INR ${(item.quantity * item.price).toFixed(2)}`
                ];
            }),
            startY: 80,
            headStyles: { fillColor: [240, 240, 240], textColor: [0, 0, 0], fontStyle: 'bold' },
            columnStyles: {
                1: { halign: 'center' },
                2: { halign: 'right' },
                3: { halign: 'right' }
            },
            theme: 'grid'
        });

        // --- Totals ---
        // @ts-ignore
        let finalY = doc.lastAutoTable.finalY + 10;
        const subtotalStr = (totalAmount / 1.18).toFixed(2);
        const gstStr = ((totalAmount - (totalAmount / 1.18)) / 2).toFixed(2);

        doc.setFontSize(10);
        doc.text("Subtotal:", 140, finalY);
        doc.setFont("helvetica", "bold");
        doc.text(`INR ${subtotalStr}`, 196, finalY, { align: "right" });
        
        doc.setFont("helvetica", "normal");
        doc.text("CGST (9%):", 140, finalY + 6);
        doc.text(`INR ${gstStr}`, 196, finalY + 6, { align: "right" });
        
        doc.text("SGST (9%):", 140, finalY + 12);
        doc.text(`INR ${gstStr}`, 196, finalY + 12, { align: "right" });
        
        doc.setLineWidth(0.5);
        doc.line(140, finalY + 16, 196, finalY + 16);
        
        doc.setFontSize(12);
        doc.setFont("helvetica", "bold");
        doc.text("GRAND TOTAL", 140, finalY + 22);
        doc.setTextColor(37, 99, 235);
        doc.text(`INR ${totalAmount.toFixed(0)}`, 196, finalY + 22, { align: "right" });
        
        // --- Footer ---
        doc.setTextColor(0, 0, 0);
        doc.setFillColor(245, 245, 245);
        // @ts-ignore
        const pageHeight = doc.internal.pageSize.height || doc.internal.pageSize.getHeight();
        if (finalY > pageHeight - 30) { 
            doc.addPage(); 
            finalY = 20; // reset if page break happened overlapping footer
        }
        
        doc.rect(0, pageHeight - 25, 210, 25, 'F');
        
        doc.setFontSize(10);
        doc.setFont("helvetica", "italic");
        doc.text("Thank you for your business!", 105, pageHeight - 16, { align: "center" });
        
        doc.setFontSize(8);
        doc.setFont("helvetica", "normal");
        doc.setTextColor(100, 100, 100);
        doc.text("Terms & Conditions: Goods once sold will not be taken back. Interest @ 18% p.a. will be charged if bill is not paid within due date.", 105, pageHeight - 10, { align: "center", maxWidth: 180 });

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
