import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as dotenv from 'dotenv';
dotenv.config({ path: '.env' });

async function run() {
  console.log('Connecting to', process.env.DATABASE_URL);
  const sql = postgres(process.env.DATABASE_URL!, { max: 1 });
  
  try {
    console.log('Altering shops table...');
    await sql`ALTER TABLE "shops" ADD COLUMN IF NOT EXISTS "outstanding_balance" real DEFAULT 0 NOT NULL;`;

    console.log('Altering orders table...');
    await sql`ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "paid_amount" real DEFAULT 0 NOT NULL;`;

    console.log('Creating payments table...');
    await sql`
      CREATE TABLE IF NOT EXISTS "payments" (
        "id" text PRIMARY KEY NOT NULL,
        "order_id" text NOT NULL REFERENCES "orders"("id") ON DELETE CASCADE,
        "shop_id" integer NOT NULL REFERENCES "shops"("id") ON DELETE CASCADE,
        "salesman_id" text NOT NULL REFERENCES "user"("id") ON DELETE CASCADE,
        "amount" real NOT NULL,
        "payment_mode" text NOT NULL,
        "created_at" timestamp DEFAULT now() NOT NULL
      );
    `;

    console.log('Database updated successfully for partial payments!');
  } catch (err) {
    console.error('Migration failed:', err);
  } finally {
    await sql.end();
  }
}

run();
