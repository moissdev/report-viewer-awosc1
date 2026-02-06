-- VIEW 1: Libros más prestados 
-- Grain: Una fila por Libro.
-- Métrica: Frecuencia de préstamos y su ranking.
CREATE OR REPLACE VIEW vw_most_borrowed_books AS
SELECT 
    b.id AS book_id,
    b.title,
    b.author,
    b.category,
    COUNT(l.id) AS total_borrows,
    RANK() OVER (ORDER BY COUNT(l.id) DESC) AS borrow_rank
FROM books b
LEFT JOIN copies c ON b.id = c.book_id
LEFT JOIN loans l ON c.id = l.copy_id
GROUP BY b.id, b.title, b.author, b.category;

-- ==============================================================================
-- VIEW 2: Préstamos Vencidos
-- Grain: Una fila por Préstamo vencido.
-- Métrica: Días de retraso y el cálculo de la multa sugerida.
CREATE OR REPLACE VIEW vw_overdue_loans AS
WITH overdue_calc AS (
    SELECT 
        l.id AS loan_id,
        m.name AS member_name,
        b.title AS book_title,
        l.due_at,
        l.returned_at,
        (COALESCE(l.returned_at::DATE, CURRENT_DATE) - l.due_at::DATE) AS days_overdue
    FROM loans l
    JOIN members m ON l.member_id = m.id
    JOIN copies c ON l.copy_id = c.id
    JOIN books b ON c.book_id = b.id
    WHERE l.due_at < COALESCE(l.returned_at, CURRENT_TIMESTAMP)
)
SELECT 
    loan_id,
    member_name,
    book_title,
    due_at,
    returned_at,
    days_overdue,
    CASE 
        WHEN days_overdue <= 0 THEN 0
        WHEN (days_overdue * 1.50) > 50 THEN 50.00
        ELSE (days_overdue * 1.50)
    END AS suggested_fine_amount
FROM overdue_calc
WHERE days_overdue > 0;

-- ==============================================================================
-- VIEW 3: Resumen Mensual de Multas
-- Grain: Una fila por Mes.
-- Métrica: Dinero recaudado vs Dinero pendiente de cobrar.
CREATE OR REPLACE VIEW vw_fines_summary AS
SELECT 
    TO_CHAR(COALESCE(paid_at, CURRENT_TIMESTAMP), 'YYYY-MM') AS fine_month,
    COUNT(id) AS total_fines,
    SUM(amount) AS total_amount,
    COALESCE(SUM(amount) FILTER (WHERE paid_at IS NOT NULL), 0) AS collected_amount,
    COALESCE(SUM(amount) FILTER (WHERE paid_at IS NULL), 0) AS pending_amount
FROM fines
GROUP BY TO_CHAR(COALESCE(paid_at, CURRENT_TIMESTAMP), 'YYYY-MM')
HAVING COUNT(id) > 0;

-- ==============================================================================
-- VIEW 4: Actividad de Socios
-- Grain: Una fila por Socio.
-- Métrica: Nivel de actividad del usuario y su tasa de atraso.
CREATE OR REPLACE VIEW vw_member_activity AS
SELECT 
    m.id AS member_id,
    m.name,
    m.member_type,
    COUNT(l.id) AS total_loans,
    SUM(CASE WHEN l.due_at < COALESCE(l.returned_at, CURRENT_TIMESTAMP) THEN 1 ELSE 0 END) AS overdue_loans,
    ROUND(
        (SUM(CASE WHEN l.due_at < COALESCE(l.returned_at, CURRENT_TIMESTAMP) THEN 1 ELSE 0 END)::numeric / 
        NULLIF(COUNT(l.id), 0)) * 100, 
    2) AS overdue_rate_percentage
FROM members m
LEFT JOIN loans l ON m.id = l.member_id
GROUP BY m.id, m.name, m.member_type
HAVING COUNT(l.id) > 0;

-- ==============================================================================
-- VIEW 5: Salud del Inventario 
-- Grain: Una fila por Categoría de Libro.
-- Métrica: Distribución del estado físico de los libros en la biblioteca.
CREATE OR REPLACE VIEW vw_inventory_health AS
SELECT 
    COALESCE(b.category, 'Sin Categoría') AS category,
    COUNT(c.id) AS total_copies,
    SUM(CASE WHEN c.status = 'available' THEN 1 ELSE 0 END) AS available_copies,
    SUM(CASE WHEN c.status = 'borrowed' THEN 1 ELSE 0 END) AS borrowed_copies,
    SUM(CASE WHEN c.status = 'lost' THEN 1 ELSE 0 END) AS lost_copies,
    ROUND(
        (SUM(CASE WHEN c.status = 'lost' THEN 1 ELSE 0 END)::numeric / 
        NULLIF(COUNT(c.id), 0)) * 100, 
    2) AS loss_rate_percentage
FROM books b
LEFT JOIN copies c ON b.id = c.book_id
GROUP BY b.category;

-- ==============================================================================
-- Sección de permisos para el usuario de NextJS
GRANT SELECT ON vw_most_borrowed_books TO app_user;
GRANT SELECT ON vw_overdue_loans TO app_user;
GRANT SELECT ON vw_fines_summary TO app_user;
GRANT SELECT ON vw_member_activity TO app_user;
GRANT SELECT ON vw_inventory_health TO app_user;