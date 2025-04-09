# 🔥 Spark ETL Project

Projekt pro zpracování dat pomocí Apache Spark a uložení do PostgreSQL databáze.

## 🚀 Funkce

- ⚡ ETL proces pomocí Apache Spark
- 🐘 Ukládání dat do PostgreSQL
- 🐳 Kompletní Docker prostředí
- 🧮 Transformace CSV dat
- 📊 Správa pomocí pgAdmin

## 📊 Architektura

Projekt se skládá z několika komponent:

1. **Spark ETL Kontejner** - Zpracovává a transformuje data z CSV souborů
2. **PostgreSQL Databáze** - Uložiště pro transformovaná data
3. **pgAdmin** - Webové rozhraní pro správu databáze

## 🛠️ Technologie

- Apache Spark 3.5.0
- Python 3.11
- PostgreSQL
- Docker & Docker Compose

## ⚙️ Instalace a spuštění

### Požadavky
- Docker a Docker Compose

### Spuštění

```bash
# Sestavení a spuštění všech služeb
docker-compose up -d

# Spuštění ETL procesu
docker-compose up spark-etl
```

### Přístup k pgAdmin

- URL: http://localhost:5050
- Email: admin@example.com
- Heslo: admin

## 📁 Struktura projektu

```
.
├── Dockerfile             # Definice Docker image pro Spark ETL
├── docker-compose.yml     # Konfigurace služeb
├── data/                  # Adresář se zdrojovými daty
│   └── users.csv          # Vzorová data
├── db-init/               # SQL skripty pro inicializaci databáze
│   └── 01_create_users_table.sql
├── pgadmin/               # Konfigurace pgAdmin
│   ├── pgpassfile
│   └── servers.json
└── pyspark_etl_project/   # Python kód pro ETL
    ├── __init__.py
    └── etl.py             # Hlavní ETL skript
```

## 📝 Licence

MIT 