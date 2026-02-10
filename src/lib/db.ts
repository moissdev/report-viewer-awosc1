import { Pool } from 'pg';

const pool = new Pool({
  user: process.env.APP_USER,
  password: process.env.APP_PASSWORD,
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.POSTGRES_DB,
});

export async function query(text: string, params?: (string | number | boolean | Date | null)[]) {
  const start = Date.now();
  const res = await pool.query(text, params);
  const duration = Date.now() - start;
  console.log(`[DB Query] ejecutado en ${duration}ms, filas: ${res.rowCount}`);
  return res;
}

export default pool;