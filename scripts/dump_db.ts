import postgres from 'postgres';
import * as dotenv from 'dotenv';
import fs from 'fs';
dotenv.config({ path: '.env' });

async function run() {
  const sql = postgres(process.env.DATABASE_URL!, { max: 1 });
  
  try {
    const orders = await sql`SELECT * FROM orders ORDER BY created_at DESC`;
    const payments = await sql`SELECT * FROM payments ORDER BY created_at DESC`;
    const shops = await sql`SELECT * FROM shops ORDER BY id ASC`;

    const report = {
      orders,
      payments,
      shops
    };

    fs.writeFileSync('db_dump.json', JSON.stringify(report, null, 2));
    console.log('Report written to db_dump.json');

  } catch (err) {
    console.error('Debug failed:', err);
  } finally {
    await sql.end();
  }
}

run();
