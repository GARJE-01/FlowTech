import { db } from "@/db";
import { shops } from "@/db/schema";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { AddShopDialog } from "@/components/shops/add-shop-dialog";
import { ShopCSVImport } from "@/components/shops/shop-csv-import";
import { DeleteShopButton } from "@/components/shops/delete-shop-button";

export default async function ShopsPage() {
    const allShops = await db.select().from(shops);

    return (
        <div className="flex flex-col gap-4">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold tracking-tight">Shops</h1>
                <div className="flex gap-2">
                    <ShopCSVImport />
                    <AddShopDialog />
                </div>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Shop List</CardTitle>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Shop Name</TableHead>
                                <TableHead>Owner Name</TableHead>
                                <TableHead>City</TableHead>
                                <TableHead>Mobile</TableHead>
                                <TableHead>GSTIN</TableHead>
                                <TableHead>Address</TableHead>
                                <TableHead className="text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {allShops.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={7} className="h-24 text-center text-muted-foreground">
                                        No shops found. Add one or import from CSV.
                                    </TableCell>
                                </TableRow>
                            ) : (
                                allShops.map((shop) => (
                                    <TableRow key={shop.id}>
                                        <TableCell className="font-medium">{shop.shopName}</TableCell>
                                        <TableCell>{shop.ownerName}</TableCell>
                                        <TableCell>{shop.city}</TableCell>
                                        <TableCell>{shop.mobileNumber}</TableCell>
                                        <TableCell>{shop.gstNumber || "-"}</TableCell>
                                        <TableCell className="max-w-[200px] truncate" title={shop.address}>
                                            {shop.address}
                                        </TableCell>
                                        <TableCell className="text-right">
                                            <DeleteShopButton shopId={shop.id} shopName={shop.shopName} />
                                        </TableCell>
                                    </TableRow>
                                ))
                            )}
                        </TableBody>
                    </Table>
                </CardContent>
            </Card>
        </div>
    );
}
