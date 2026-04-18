import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

// Connection string from your .env / Vercel environment variables
const connectionString = process.env.DATABASE_URL!;

// IMPORTANT: prepare: false is required for Supabase connection pooler (port 6543 / PgBouncer).
// Without this, Vercel serverless functions will crash with 'prepared statement already exists'.
const client = postgres(connectionString, { prepare: false });
export const db = drizzle(client, { schema });
