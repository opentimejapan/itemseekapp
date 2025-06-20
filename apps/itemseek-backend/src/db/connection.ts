import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from '@itemseek/db';

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL environment variable is required');
}

// Create PostgreSQL connection
const sql = postgres(process.env.DATABASE_URL, {
  max: 10, // Connection pool size
  idle_timeout: 20,
  connect_timeout: 10,
});

// Create Drizzle instance
export const db = drizzle(sql, { schema });

// Export for migrations
export { sql };