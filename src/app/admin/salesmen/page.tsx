
import { db } from "@/db";
import { user } from "@/db/schema";
import { eq } from "drizzle-orm";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { AddSalesmanDialog } from "@/components/salesmen/add-salesman-dialog";
import { Badge } from "@/components/ui/badge";

export default async function SalesmenPage() {
    const salesmen = await db.select().from(user).where(eq(user.role, "salesman"));
    const admins = await db.select().from(user).where(eq(user.role, "admin"));
    const allUsers = [...admins, ...salesmen]; // Show all for admin

    return (
        <div className="flex flex-col gap-4">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold tracking-tight">Salesmen & Users</h1>
                <AddSalesmanDialog />
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>User Management</CardTitle>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Name</TableHead>
                                <TableHead>Email</TableHead>
                                <TableHead>Role</TableHead>
                                <TableHead>Created At</TableHead>
                                <TableHead className="text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {allUsers.map((user) => (
                                <TableRow key={user.id}>
                                    <TableCell className="font-medium">{user.name}</TableCell>
                                    <TableCell>{user.email}</TableCell>
                                    <TableCell>
                                        <Badge variant={user.role === 'admin' ? 'default' : 'secondary'}>
                                            {user.role}
                                        </Badge>
                                    </TableCell>
                                    <TableCell>{user.createdAt ? new Date(user.createdAt).toLocaleDateString() : "-"}</TableCell>
                                    <TableCell className="text-right">
                                        {/* Actions like Edit/Delete */}
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
