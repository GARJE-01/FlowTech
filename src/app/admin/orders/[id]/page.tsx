export const dynamic = "force-dynamic";

import { getOrder } from "@/db/queries";
import { notFound } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { OrderActions } from "@/components/orders/order-actions";

export default async function OrderDetailPage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = await params;
    const order = await getOrder(id);

    if (!order) return notFound();

    return (
        <div className="flex flex-col gap-4">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold tracking-tight">Order Details</h1>
                <OrderActions
                    orderId={order.id}
                    status={order.status || 'pending'}
                    items={order.items}
                    totalAmount={order.totalAmount}
                    shopName={order.shopName || ''}
                    shopAddress={order.shopAddress || ''}
                    shopGST={order.shopGST || ''}
                    salesmanName={order.salesmanName || ''}
                    createdAt={order.createdAt!}
                />
            </div>

            <div className="grid gap-4 md:grid-cols-3">
                <Card className="col-span-2">
                    <CardHeader>
                        <CardTitle>Order Items</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>Product</TableHead>
                                    <TableHead>SKU</TableHead>
                                    <TableHead>Price</TableHead>
                                    <TableHead>Quantity</TableHead>
                                    <TableHead className="text-right">Total</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {order.items.map((item) => (
                                    <TableRow key={item.id}>
                                        <TableCell>{item.productName} {item.variantName ? `(${item.variantName})` : ''}</TableCell>
                                        <TableCell>{item.sku}</TableCell>
                                        <TableCell>₹{item.price.toFixed(2)}</TableCell>
                                        <TableCell>{item.quantity}</TableCell>
                                        <TableCell className="text-right">₹{(item.price * item.quantity).toFixed(2)}</TableCell>
                                    </TableRow>
                                ))}
                                <TableRow>
                                    <TableCell colSpan={4} className="font-bold text-right">Grand Total</TableCell>
                                    <TableCell className="font-bold text-right">₹{order.totalAmount.toFixed(2)}</TableCell>
                                </TableRow>
                            </TableBody>
                        </Table>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader>
                        <CardTitle>Info</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-2">
                        <div className="flex justify-between">
                            <span className="text-muted-foreground">Order ID:</span>
                            <span className="font-medium">{order.id}</span>
                        </div>
                        <div className="flex justify-between">
                            <span className="text-muted-foreground">Date:</span>
                            <span className="font-medium">{order.createdAt ? new Date(order.createdAt).toLocaleDateString() : "-"}</span>
                        </div>
                        <div className="flex justify-between items-center">
                            <span className="text-muted-foreground">Status:</span>
                            <Badge variant={
                                order.status === 'approved' ? 'default' :
                                    order.status === 'rejected' ? 'destructive' : 'outline'
                            }>
                                {order.status}
                            </Badge>
                        </div>
                        <div className="flex justify-between">
                            <span className="text-muted-foreground">Salesman:</span>
                            <span className="font-medium">{order.salesmanName || "Unknown"}</span>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
