-- Vytvoření tabulky users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vytvoření indexu pro rychlejší vyhledávání podle emailu
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Vytvoření indexu pro rychlejší vyhledávání podle username
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Vytvoření triggeru pro automatickou aktualizaci updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Vložení ukázkových dat
INSERT INTO users (username, email, first_name, last_name)
VALUES 
    ('john_doe', 'john.doe@example.com', 'John', 'Doe'),
    ('jane_smith', 'jane.smith@example.com', 'Jane', 'Smith'),
    ('bob_wilson', 'bob.wilson@example.com', 'Bob', 'Wilson')
ON CONFLICT (username) DO NOTHING; 