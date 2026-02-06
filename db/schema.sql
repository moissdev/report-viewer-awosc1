CREATE TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    member_type VARCHAR(50) DEFAULT 'standard',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    isbn VARCHAR(20) UNIQUE
);

CREATE TABLE IF NOT EXISTS copies (
    id SERIAL PRIMARY KEY,
    book_id INT REFERENCES books(id) ON DELETE CASCADE,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'borrowed', 'lost'))
);

CREATE TABLE IF NOT EXISTS loans (
    id SERIAL PRIMARY KEY,
    copy_id INT REFERENCES copies(id),
    member_id INT REFERENCES members(id),
    loaned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_at TIMESTAMP NOT NULL,
    returned_at TIMESTAMP -- Si llega a ser Null entonces significa que no ha sido devuelto
);

CREATE TABLE IF NOT EXISTS fines (
    id SERIAL PRIMARY KEY,
    loan_id INT REFERENCES loans(id),
    amount DECIMAL(10, 2) NOT NULL,
    paid_at TIMESTAMP -- Null significaría que la multa está pendiente
);