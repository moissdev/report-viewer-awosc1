// src/lib/db.ts
import { Pool } from 'pg';

const poolConfig = {
  user: process.env.APP_USER,
  password: process.env.APP_PASSWORD,
  host: 'localhost',
  port: 5433,
  database: process.env.POSTGRES_DB,
};

const globalForPg = global as unknown as { pgPool: Pool };

const pool = globalForPg.pgPool || new Pool(poolConfig);

if (process.env.NODE_ENV !== 'production') {
  globalForPg.pgPool = pool;
}

export async function query(text: string, params?: (string | number | boolean | Date | null)[]) {
  console.log(`[Ejecutando SQL]: ${text}`);
  const start = Date.now();
  const res = await pool.query(text, params);
  const duration = Date.now() - start;
  console.log(`[DB Query] ejecutado en ${duration}ms, filas: ${res.rowCount}`);
  return res;
}

export default pool;