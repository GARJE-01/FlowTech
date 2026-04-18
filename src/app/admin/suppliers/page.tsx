export const dynamic = "force-dynamic";

import { db } from "@/db";
import { suppliers } from "@/db/schema";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { SupplierDialog } from "@/components/suppliers/supplier-dialog";
import { SupplierCSVImport } from "@/components/suppliers/supplier-csv-import";

export default async function SuppliersPage() {
    const allSuppliers = await db.select().from(suppliers);

    return (
        <div className="flex flex-col gap-4">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold tracking-tight">Suppliers</h1>
                <div className="flex gap-2">
                    <SupplierCSVImport />
                    <SupplierDialog />
                </div>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Supplier List</CardTitle>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Name</TableHead>
                                <TableHead>Contact Person</TableHead>
                                <TableHead>Email</TableHead>
                                <TableHead>Phone</TableHead>
                                <TableHead className="text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {allSuppliers.map((supplier) => (
                                <TableRow key={supplier.id}>
                                    <TableCell className="font-medium">{supplier.name}</TableCell>
                                    <TableCell>{supplier.contactPerson || "-"}</TableCell>
                                    <TableCell>{supplier.email || "-"}</TableCell>
                                    <TableCell>{supplier.phone || "-"}</TableCell>
                                    <TableCell className="text-right">
                                        <SupplierDialog supplier={supplier} />
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
