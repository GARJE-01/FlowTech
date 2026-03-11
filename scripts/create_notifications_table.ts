import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as dotenv from 'dotenv';
dotenv.config({ path: '.env' });

async function run() {
  console.log('Connecting to', process.env.DATABASE_URL);
  const sql = postgres(process.env.DATABASE_URL!, { max: 1 });
  const db = drizzle(sql);
  
  try {
    console.log('Creating notifications table...');
    await sql`
      CREATE TABLE IF NOT EXISTS "notifications" (
        "id" text PRIMARY KEY NOT NULL,
        "salesman_id" text NOT NULL,
        "type" text NOT NULL,
        "title" text NOT NULL,
        "message" text NOT NULL,
        "related_id" text,
        "is_new" boolean DEFAULT true NOT NULL,
        "created_at" timestamp DEFAULT now() NOT NULL
      );
    `;
    console.log('Adding constraints...');
    await sql`
      DO $$ BEGIN
        ALTER TABLE "notifications" ADD CONSTRAINT "notifications_salesman_id_user_id_fk" FOREIGN KEY ("salesman_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `;
    console.log('Done!');
  } catch (err) {
    console.error(err);
  } finally {
    await sql.end();
  }
}

run();
