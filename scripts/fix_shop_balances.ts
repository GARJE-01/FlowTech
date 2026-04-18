import postgres from 'postgres';
import * as dotenv from 'dotenv';
dotenv.config({ path: '.env' });

async function run() {
  const sql = postgres(process.env.DATABASE_URL!, { max: 1 });
  
  try {
    console.log('Recalculating shop balances...');
    
    const shops = await sql`SELECT id FROM shops`;
    
    for (const shop of shops) {
      // 1. Sum Approved Orders
      const orderSum = await sql`
        SELECT SUM(total_amount) as total 
        FROM orders 
        WHERE shop_id = ${shop.id} AND status IN ('approved', 'delivered')
      `;
      const totalOwed = parseFloat(orderSum[0].total || 0);

      // 2. Sum Payments
      const paymentSum = await sql`
        SELECT SUM(amount) as total 
        FROM payments 
        WHERE shop_id = ${shop.id}
      `;
      const totalPaid = parseFloat(paymentSum[0].total || 0);

      const newBalance = totalOwed - totalPaid;

      console.log(`Shop #${shop.id}: Owed ${totalOwed}, Paid ${totalPaid} -> New Balance ${newBalance}`);

      await sql`
        UPDATE shops 
        SET outstanding_balance = ${newBalance} 
        WHERE id = ${shop.id}
      `;
    }

    console.log('Shop balances recalculated successfully!');
  } catch (err) {
    console.error('Fix failed:', err);
  } finally {
    await sql.end();
  }
}

run();
