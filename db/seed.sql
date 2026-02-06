INSERT INTO members (name, email, member_type, joined_at) VALUES
('Ana Silva', 'ana@email.com', 'premium', '2025-01-10'),
('Luis Torres', 'luis@email.com', 'standard', '2025-01-15'),
('Carmen Rios', 'carmen@email.com', 'student', '2025-02-01');

INSERT INTO books (title, author, category, isbn) VALUES
('Cien Años de Soledad', 'Gabriel García Márquez', 'Ficción', '978-0307474728'),
('Clean Code', 'Robert C. Martin', 'Tecnología', '978-0132350884'),
('Sapiens', 'Yuval Noah Harari', 'Historia', '978-0062316097');

INSERT INTO copies (book_id, barcode, status) VALUES
(1, 'B001-1', 'available'),
(1, 'B001-2', 'borrowed'),
(2, 'B002-1', 'borrowed'),
(3, 'B003-1', 'lost'),
(3, 'B003-2', 'available');

INSERT INTO loans (copy_id, member_id, loaned_at, due_at, returned_at) VALUES
(2, 1, '2025-02-01 10:00:00', '2025-02-15 10:00:00', NULL), 
(3, 2, '2025-02-10 11:00:00', '2025-02-24 11:00:00', NULL), 
(1, 3, '2025-01-20 09:00:00', '2025-02-05 09:00:00', '2025-02-08 14:00:00');

INSERT INTO fines (loan_id, amount, paid_at) VALUES
(1, 15.50, NULL), 
(3, 5.00, '2025-02-08 14:05:00'); 