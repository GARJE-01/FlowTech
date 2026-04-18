import postgres from 'postgres';
import * as dotenv from 'dotenv';
dotenv.config({ path: '.env' });

async function run() {
  console.log('Connecting to', process.env.DATABASE_URL);
  const sql = postgres(process.env.DATABASE_URL!, { max: 1 });
  
  try {
    console.log('Ensuring all columns exist in orders table...');
    
    // Add is_paid
    await sql`ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "is_paid" boolean DEFAULT false NOT NULL;`;
    
    // Add updatedAt if missing
    await sql`ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "updated_at" timestamp DEFAULT now();`;
    
    // Add approver_id if missing
    await sql`ALTER TABLE "orders" ADD COLUMN IF NOT EXISTS "approver_id" text REFERENCES "user"("id") ON DELETE CASCADE;`;

    // Also double check shops for outstanding_balance (just in case)
    await sql`ALTER TABLE "shops" ADD COLUMN IF NOT EXISTS "outstanding_balance" real DEFAULT 0 NOT NULL;`;

    console.log('Database fix applied successfully!');
  } catch (err) {
    console.error('Fix failed:', err);
  } finally {
    await sql.end();
  }
}

run();
