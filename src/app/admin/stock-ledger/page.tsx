export const dynamic = "force-dynamic";

import { getStockLedger } from "@/db/queries";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export default async function StockLedgerPage() {
    const ledger = await getStockLedger();

    return (
        <div className="flex flex-col gap-4">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold tracking-tight">Stock Ledger</h1>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Transactions</CardTitle>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Date</TableHead>
                                <TableHead>Type</TableHead>
                                <TableHead>Product</TableHead>
                                <TableHead>SKU</TableHead>
                                <TableHead>Change</TableHead>
                                <TableHead>Ref/Supplier</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {ledger.map((entry) => (
                                <TableRow key={entry.id}>
                                    <TableCell>{entry.date ? new Date(entry.date).toLocaleString() : "-"}</TableCell>
                                    <TableCell>
                                        <Badge variant={entry.type === 'STOCK_IN' ? 'default' : 'secondary'}>
                                            {entry.type}
                                        </Badge>
                                    </TableCell>
                                    <TableCell>{entry.productName}</TableCell>
                                    <TableCell>{entry.variantSku}</TableCell>
                                    <TableCell className={entry.changeAmount > 0 ? "text-green-600" : "text-red-600"}>
                                        {entry.changeAmount > 0 ? "+" : ""}{entry.changeAmount}
                                    </TableCell>
                                    <TableCell>
                                        {entry.supplierName || entry.notes || "-"}
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
