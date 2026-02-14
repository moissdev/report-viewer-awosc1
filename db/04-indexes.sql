-- Este índice sirve para optimizar cálculos de fechas
-- Esto porque ambas vistas comparan constantemente 'due_at' con 'returned_at' para saber si hay atraso.
CREATE INDEX idx_loans_dates ON loans(due_at, returned_at);

-- Este índice ayuda a optimizar agrupaciones por fecha en multas
-- La vista de multas agrupa (GROUP BY) y filtra a la vez usando la fecha de pago.
CREATE INDEX idx_fines_paid_at ON fines(paid_at);

-- Este índice permite optimizar los JOINs entre copias y libros 
-- Las FK no tienen índices automáticos en Postgres, y como unimos copies con books frecuentemente, esto acelera este JOIN.
CREATE INDEX idx_copies_book_id ON copies(book_id);