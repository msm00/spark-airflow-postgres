-- Skript pro vytvoření tabulek a inicializaci databáze
-- Vytvořeno pro projekt spark-airflow-postgres

-- Vytvoření tabulky users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Metadata pro sledování
    owner VARCHAR(50) DEFAULT 'data_team',
    sensitivity_level VARCHAR(20) DEFAULT 'low',
    retention_period VARCHAR(20) DEFAULT '1 year'
);

-- Vytvoření indexů pro optimalizaci dotazů
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

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

-- Vytvoření tabulky pro data quality check
CREATE TABLE IF NOT EXISTS data_quality_results (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    check_name VARCHAR(100) NOT NULL,
    passed BOOLEAN NOT NULL,
    records_checked INT,
    records_failed INT,
    execution_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    execution_by VARCHAR(50) DEFAULT CURRENT_USER
);

-- Vytvoření tabulky pro metriky ETL procesů
CREATE TABLE IF NOT EXISTS etl_metrics (
    id SERIAL PRIMARY KEY,
    dag_id VARCHAR(100),
    task_id VARCHAR(100),
    execution_date TIMESTAMP,
    records_processed INT,
    execution_time_seconds NUMERIC,
    status VARCHAR(20),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vložení ukázkových dat pro testování
INSERT INTO users (username, email, first_name, last_name)
VALUES 
    ('admin_user', 'admin@example.com', 'Admin', 'User'),
    ('test_user', 'test@example.com', 'Test', 'User')
ON CONFLICT (username) DO NOTHING;

-- Grant oprávnění pro Airflow a Spark
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- Komentáře k tabulkám pro lepší dokumentaci
COMMENT ON TABLE users IS 'Tabulka uživatelů zpracovaná ETL pipelineou';
COMMENT ON TABLE data_quality_results IS 'Výsledky kontrol kvality dat';
COMMENT ON TABLE etl_metrics IS 'Metriky výkonu ETL procesů';

-- Vytvoření schématu pro airflow, pokud existuje oddělená databáze
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'airflow') THEN
        PERFORM dblink_exec('dbname=' || current_database(), 'CREATE DATABASE airflow');
    END IF;
END
$$; 