import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DollarSign, Package, ShoppingCart, Users, Store, CheckCircle, ClipboardList, Wallet } from "lucide-react";
import { OverviewChart } from "@/components/dashboard/overview-chart";
import { db } from "@/db";
import { orders, productVariants, user, shops } from "@/db/schema";
import { eq, sum, count, desc, sql, gte, and, ne } from "drizzle-orm";

export default async function AdminDashboard() {
    // 1. Total Revenue (delivered orders)
    const revenueResult = await db.select({ total: sum(orders.totalAmount) }).from(orders).where(eq(orders.status, 'delivered'));
    const totalRevenue = Number(revenueResult[0]?.total || 0);

    // 2. Pending Orders
    const pendingResult = await db.select({ count: count() }).from(orders).where(eq(orders.status, 'pending'));
    const pendingCount = pendingResult[0]?.count || 0;

    // 3. Products in Stock
    const stockResult = await db.select({ total: sum(productVariants.currentStock) }).from(productVariants);
    const totalStock = Number(stockResult[0]?.total || 0);

    // 4. Active Salesmen
    const salesmenResult = await db.select({ count: count() }).from(user).where(eq(user.role, 'salesman'));
    const salesmenCount = salesmenResult[0]?.count || 0;

    // 5. Total Shops
    const totalShopsResult = await db.select({ count: count() }).from(shops);
    const totalShopsCount = totalShopsResult[0]?.count || 0;

    // 6. Active Shops
    const activeShopsResult = await db.select({ count: count() }).from(shops).where(eq(shops.isActive, true));
    const activeShopsCount = activeShopsResult[0]?.count || 0;

    // 7. Today's Orders
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayOrdersResult = await db.select({ count: count() }).from(orders).where(gte(orders.createdAt, today));
    const todayOrdersCount = todayOrdersResult[0]?.count || 0;

    // 8. Pending Payments (unpaid orders that are not rejected)
    const pendingPaymentsResult = await db.select({ total: sum(orders.totalAmount) })
        .from(orders)
        .where(and(eq(orders.isPaid, false), ne(orders.status, 'rejected')));
    const pendingPayments = Number(pendingPaymentsResult[0]?.total || 0);

    // 9. Chart Data (Revenue per month for current year)
    const chartDataResult = await db.execute(sql`
        SELECT 
            to_char(created_at, 'Mon') as name,
            SUM(total_amount) as total
        FROM orders
        WHERE status = 'delivered' AND created_at >= date_trunc('year', CURRENT_DATE)
        GROUP BY name, date_trunc('month', created_at)
        ORDER BY date_trunc('month', created_at)
    `);

    const allMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const chartData = allMonths.map(month => {
        const found = chartDataResult.find((r: any) => r.name === month);
        return { name: month, total: found ? Number(found.total) : 0 };
    });

    // 10. Recent Sales (last 5 orders)
    const recentSales = await db.select({
        id: orders.id,
        amount: orders.totalAmount,
        salesmanName: user.name,
        salesmanEmail: user.email,
        createdAt: orders.createdAt,
    })
    .from(orders)
    .leftJoin(user, eq(orders.salesmanId, user.id))
    .orderBy(desc(orders.createdAt))
    .limit(5);

    return (
        <div className="flex flex-1 flex-col gap-4 p-4 pt-0">
            {/* Row 1: Key Financials & Logistics */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
                        <DollarSign className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">₹{totalRevenue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</div>
                    </CardContent>
                </Card>
                <Card className="bg-orange-50/50 dark:bg-orange-950/10">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium text-orange-600 dark:text-orange-400">Pending Payments</CardTitle>
                        <Wallet className="h-4 w-4 text-orange-600 dark:text-orange-400" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-orange-700 dark:text-orange-300">₹{pendingPayments.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</div>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Pending Orders</CardTitle>
                        <ShoppingCart className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{pendingCount}</div>
                    </CardContent>
                </Card>
                <Card className="bg-blue-50/50 dark:bg-blue-950/10">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium text-blue-600 dark:text-blue-400">Today&apos;s Orders</CardTitle>
                        <ClipboardList className="h-4 w-4 text-blue-600 dark:text-blue-400" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-blue-700 dark:text-blue-300">{todayOrdersCount}</div>
                    </CardContent>
                </Card>
            </div>

            {/* Row 2: Shops & Salesmen */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Shops</CardTitle>
                        <Store className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{totalShopsCount}</div>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Active Shops</CardTitle>
                        <CheckCircle className="h-4 w-4 text-emerald-500" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{activeShopsCount}</div>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Active Salesmen</CardTitle>
                        <Users className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{salesmenCount}</div>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Stock Levels</CardTitle>
                        <Package className="h-4 w-4 text-muted-foreground" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{totalStock}</div>
                    </CardContent>
                </Card>
            </div>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
                <Card className="col-span-4">
                    <CardHeader>
                        <CardTitle>Overview</CardTitle>
                    </CardHeader>
                    <CardContent className="pl-2">
                        <OverviewChart data={chartData} />
                    </CardContent>
                </Card>
                <Card className="col-span-3 overflow-hidden">
                    <CardHeader>
                        <CardTitle>Recent Sales</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-8">
                            {recentSales.map((sale) => (
                                <div key={sale.id} className="flex items-center">
                                    <div className="space-y-1">
                                        <p className="text-sm font-medium leading-none">{sale.salesmanName || "Unknown"}</p>
                                        <p className="text-sm text-muted-foreground">
                                            {sale.salesmanEmail || "N/A"}
                                        </p>
                                    </div>
                                    <div className="ml-auto font-medium text-emerald-600">+₹{sale.amount.toLocaleString(undefined, { minimumFractionDigits: 2 })}</div>
                                </div>
                            ))}
                            {recentSales.length === 0 && (
                                <p className="text-sm text-muted-foreground">No recent sales recorded yet.</p>
                            )}
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
