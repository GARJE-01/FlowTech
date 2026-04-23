import postgres from 'postgres';

const sql = postgres('postgresql://postgres.mfjbifawclsfkwulzrrj:Shizuk%40123%23@aws-1-ap-south-1.pooler.supabase.com:6543/postgres', { prepare: false });

// Check order statuses
const orders = await sql`SELECT id, status, total_amount, created_at FROM orders ORDER BY created_at DESC`;
console.log("=== ALL ORDERS STATUS ===");
for (const o of orders) {
  console.log(`${o.id}: status=${o.status}, total=₹${o.total_amount}, date=${o.created_at}`);
}

// Check what the chart query returns
const chartData = await sql`
  SELECT 
    to_char(created_at, 'Mon') as name,
    SUM(total_amount) as total
  FROM orders
  WHERE status = 'delivered' AND created_at >= date_trunc('year', CURRENT_DATE)
  GROUP BY name, date_trunc('month', created_at)
  ORDER BY date_trunc('month', created_at)
`;
console.log("\n=== CHART DATA (delivered orders only) ===");
console.log(JSON.stringify(chartData, null, 2));
console.log(`Chart has ${chartData.length} data points`);

await sql.end();
