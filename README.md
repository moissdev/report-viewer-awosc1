# Report viewer AWOS
Actividad de evalución del 1er corte de la materia de AWOS. Una aplicación web hecha con Next.js que ayude a visualizar reportes SQL obtenidos de VIEWS desde una base de datos de PostgreSQL.

## Ejecución del proyecto

Toda la infraestructura (Base de datos, tablas, views, seeds, roles e índices) se inicializa automáticamente con un solo comando:

docker compose up --build

Posteriormente, se necesitan instalar las dependencias de Next.js y correr el entorno de desarrollo:


npm install
npm run dev

Una vez ejecutados estos comandos, hay que acceder al "localhost:3000"

## Justificación de los índices SQL

Para garantizar que las Views SQL respondan en milisegundos aún al escalar el volumen de datos, se crearon los siguientes 3 índices en "db/04-indexes.sql":

1. **idx_loans_dates.**
   * **Razón:** Las views vw_overdue_loans y vw_member_activity dependen de calcular la diferencia entre la fecha límite (due_at) y la fecha de retorno (returned_at). Un índice compuesto en estas columnas evita escaneos secuenciales y completos a la hora de buscar préstamos morosos o activos.
2. **idx_fines_paid_at**
   * **Razón:** La vista vw_fines_summary requiere agrupar (GROUP BY) y realizar filtros condicionales (FILTER WHERE) basados en si una multa ha sido pagada o no y en qué mes. Indexar esta columna acelera en buena medida la agregación de estos reportes.
3. **idx_copies_book_id**
   * **Razón:** En PostgreSQL, las llaves foráneas no crean un índice por defecto. Ya que views como vw_most_borrowed_books y vw_inventory_health requieren hacer un JOIN constantemente de la tabla de libros con sus respectivas copias físicas, este índice agiliza el emparejamiento de registros.

*(Nota: Las evidencias del uso de EXPLAIN ANALYZE se encuentran adjuntas en el reporte de la actividad).*