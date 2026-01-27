
import { getOrders } from "@/db/queries";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Plus, Eye } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import Link from "next/link";
import { Badge } from "@/components/ui/badge";

export default async function OrdersPage() {
    const orders = await getOrders();

    return (
        <div className="flex flex-col gap-4">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold tracking-tight">Orders</h1>
                <Button asChild>
                    <Link href="/admin/orders/create">
                        <Plus className="mr-2 h-4 w-4" /> Create Order
                    </Link>
                </Button>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Recent Orders</CardTitle>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Order ID</TableHead>
                                <TableHead>Salesman</TableHead>
                                <TableHead>Status</TableHead>
                                <TableHead>Amount</TableHead>
                                <TableHead>Date</TableHead>
                                <TableHead className="text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {orders.map((order) => (
                                <TableRow key={order.id}>
                                    <TableCell className="font-medium">{order.id}</TableCell>
                                    <TableCell>{order.salesmanName || "Unknown"}</TableCell>
                                    <TableCell>
                                        <Badge variant={
                                            order.status === 'approved' ? 'default' :
                                                order.status === 'rejected' ? 'destructive' : 'outline'
                                        }>
                                            {order.status}
                                        </Badge>
                                    </TableCell>
                                    <TableCell>₹{order.totalAmount.toFixed(2)}</TableCell>
                                    <TableCell>{order.createdAt ? new Date(order.createdAt).toLocaleDateString() : "-"}</TableCell>
                                    <TableCell className="text-right">
                                        <Button variant="ghost" size="sm" asChild>
                                            <Link href={`/admin/orders/${order.id}`}>
                                                <Eye className="h-4 w-4 mr-1" /> View
                                            </Link>
                                        </Button>
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </CardContent>
            </Card>
        </div>
    );
}
