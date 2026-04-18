import postgres from 'postgres';
import * as dotenv from 'dotenv';
dotenv.config({ path: '.env' });

async function run() {
  const sql = postgres(process.env.DATABASE_URL!, { max: 1 });
  
  try {
    console.log('--- ALL ORDERS ---');
    const orders = await sql`
      SELECT id, "total_amount", "paid_amount", "is_paid", status, shop_id 
      FROM orders
      ORDER BY created_at DESC
    `;
    console.log(JSON.stringify(orders, null, 2));

    console.log('\n--- ALL PAYMENTS ---');
    const payments = await sql`
      SELECT id, "order_id", amount, "payment_mode", "shop_id" 
      FROM payments
      ORDER BY created_at DESC
    `;
    console.log(JSON.stringify(payments, null, 2));

  } catch (err) {
    console.error('Debug failed:', err);
  } finally {
    await sql.end();
  }
}

run();
