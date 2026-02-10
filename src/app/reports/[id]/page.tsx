// src/app/reports/[id]/page.tsx
import { query } from '@/lib/db';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { z } from 'zod';

// 1. Esquema de validación con Zod para los parámetros de la URL
const searchParamsSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  search: z.string().max(100).optional(),
  min_days: z.coerce.number().int().min(0).optional(),
});

// 2. Mapeo de vistas (Whitelist para seguridad)
const REPORT_MAP: Record<string, { view: string; title: string }> = {
  '1': { view: 'vw_most_borrowed_books', title: 'Libros más prestados' },
  '2': { view: 'vw_overdue_loans', title: 'Préstamos Vencidos' },
  '3': { view: 'vw_fines_summary', title: 'Resumen Mensual de Multas' },
  '4': { view: 'vw_member_activity', title: 'Actividad de Socios' },
  '5': { view: 'vw_inventory_health', title: 'Salud del Inventario' },
};

export default async function ReportPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}) {
  const { id } = await params;
  const config = REPORT_MAP[id];

  if (!config) return notFound();

  // 3. Validar los parámetros entrantes con Zod
  const rawParams = await searchParams;
  const parsed = searchParamsSchema.safeParse(rawParams);
  
  if (!parsed.success) {
    return <div className="p-8 text-red-500">Error en los parámetros de búsqueda.</div>;
  }

  const { page, search, min_days } = parsed.data;
  const limit = 10;
  const offset = (page - 1) * limit;

  // 4. Construcción segura de la consulta SQL (Parametrizada)
  let sql = `SELECT * FROM ${config.view}`;
  const sqlParams: (string | number)[] = [];
  let paramCounter = 1;

  // Filtro específico para Reporte 1 (Búsqueda por título o autor)
  if (id === '1' && search) {
    sql += ` WHERE title ILIKE $${paramCounter} OR author ILIKE $${paramCounter}`;
    sqlParams.push(`%${search}%`);
    paramCounter++;
  }

  // Filtro específico para Reporte 2 (Días de atraso mínimos)
  if (id === '2' && min_days !== undefined) {
    sql += ` WHERE days_overdue >= $${paramCounter}`;
    sqlParams.push(min_days);
    paramCounter++;
  }

  // Paginación (Se aplica a todos)
  sql += ` LIMIT $${paramCounter} OFFSET $${paramCounter + 1}`;
  sqlParams.push(limit, offset);

  // Ejecutar consulta
  const result = await query(sql, sqlParams);
  const rows = result.rows;
  const columns = rows.length > 0 ? Object.keys(rows[0]) : [];

  return (
    <main className="min-h-screen p-8 bg-slate-50">
      <div className="max-w-6xl mx-auto">
        <Link href="/" className="text-indigo-600 hover:underline mb-6 inline-block">
          &larr; Volver al Dashboard
        </Link>

        <h1 className="text-3xl font-bold text-slate-800 mb-6">{config.title}</h1>

        {/* Controles de Filtros */}
        <form className="mb-6 p-4 bg-white rounded-lg shadow-sm border border-slate-200 flex gap-4 items-end">
          {id === '1' && (
            <div>
              <label className="block text-sm text-slate-600 mb-1">Buscar por título/autor</label>
              <input 
                type="text" 
                name="search" 
                defaultValue={search || ''} 
                className="border p-2 rounded w-64 text-black"
                placeholder="Ej. Clean Code..."
              />
            </div>
          )}
          {id === '2' && (
            <div>
              <label className="block text-sm text-slate-600 mb-1">Días de atraso mínimo</label>
              <input 
                type="number" 
                name="min_days" 
                defaultValue={min_days || ''} 
                className="border p-2 rounded w-32 text-black"
                min="0"
              />
            </div>
          )}
          <button type="submit" className="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700">
            Filtrar
          </button>
          <Link href={`/reports/${id}`} className="text-sm text-slate-500 px-4 py-2">
            Limpiar
          </Link>
        </form>

        {/* Tabla de Resultados */}
        <div className="bg-white rounded-xl shadow-sm overflow-x-auto border border-slate-200">
          <table className="min-w-full text-left text-sm">
            <thead className="bg-slate-100 text-slate-600 uppercase">
              <tr>
                {columns.map((col) => (
                  <th key={col} className="px-6 py-4">{col.replace(/_/g, ' ')}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-800">
              {rows.length === 0 ? (
                <tr><td colSpan={columns.length || 1} className="p-4 text-center">No hay datos.</td></tr>
              ) : (
                rows.map((row, i) => (
                  <tr key={i} className="hover:bg-slate-50">
                    {columns.map((col) => (
                      <td key={col} className="px-6 py-4">
                        {row[col] instanceof Date ? row[col].toISOString().split('T')[0] : String(row[col] ?? '-')}
                      </td>
                    ))}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Controles de Paginación */}
        <div className="mt-6 flex gap-2">
          {page > 1 && (
            <Link 
              href={`/reports/${id}?page=${page - 1}${search ? `&search=${search}` : ''}${min_days ? `&min_days=${min_days}` : ''}`}
              className="px-4 py-2 border rounded bg-white hover:bg-slate-50 text-black"
            >
              Anterior
            </Link>
          )}
          <Link 
            href={`/reports/${id}?page=${page + 1}${search ? `&search=${search}` : ''}${min_days ? `&min_days=${min_days}` : ''}`}
            className="px-4 py-2 border rounded bg-white hover:bg-slate-50 text-black"
          >
            Siguiente
          </Link>
        </div>
      </div>
    </main>
  );
}