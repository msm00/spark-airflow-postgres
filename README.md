# 🚀 Spark-Airflow-Postgres

Projekt pro automatizaci a orchestraci ETL procesů pomocí Apache Airflow, Apache Spark a PostgreSQL.

## 🔥 Přehled

Tento projekt implementuje datovou pipeline, která automatizuje zpracování dat pomocí Apache Airflow, transformace provádí v Apache Spark a ukládá výsledky do PostgreSQL databáze.

## 🚀 Funkce

- 🌊 Automatizace a orchestrace ETL procesů pomocí Apache Airflow
- ⚡ Zpracování a transformace dat s využitím Apache Spark
- 🐘 Ukládání a přístup k datům přes PostgreSQL
- 📊 Správa databáze pomocí pgAdmin

## 📊 Architektura

Projekt využívá následující komponenty:

1. **Apache Airflow** - Orchestrace a plánování ETL procesů
2. **Apache Spark** - Zpracování a transformace dat
3. **PostgreSQL** - Persistentní uložiště pro výsledná data
4. **pgAdmin** - Webové rozhraní pro správu PostgreSQL

## ⚙️ Instalace a spuštění

### Požadavky

- Docker a Docker Compose
- Git

### Rychlé spuštění

```bash
# Klonování repozitáře
git clone https://github.com/msm00/spark-airflow-postgres.git
cd spark-airflow-postgres

# Kopírování konfiguračního souboru
cp .env.example .env

# Spuštění služeb
docker-compose up -d
```

### Přístup k webovým rozhraním

- **Airflow**: http://localhost:8080
  - Uživatel: airflow
  - Heslo: airflow
- **pgAdmin**: http://localhost:5050
  - Email: admin@example.com
  - Heslo: admin
- **Spark UI**: http://localhost:8090 (dostupné během běhu Spark úlohy)

## 📋 Použití

### Spuštění ETL procesu

ETL procesy jsou definovány jako Airflow DAGy v adresáři `airflow/dags`. Proces můžete spustit manuálně z Airflow UI nebo se spustí automaticky podle nastaveného rozvrhu.

### Vytvoření Spark jobu

1. Přidejte nový Python soubor do adresáře `spark_jobs/`
2. Implementujte transformační logiku
3. Integrujte Spark job s Airflow pomocí SparkSubmitOperator

## 📁 Struktura projektu

```
.
├── airflow/                     # Apache Airflow konfigurace
│   ├── dags/                    # DAG definice
│   │   └── spark_etl_dag.py     # Ukázkový ETL DAG
│   └── plugins/                 # Airflow pluginy
├── spark_jobs/                  # Spark transformační skripty
│   └── etl_process.py           # Ukázkový Spark job
├── db-init/                     # SQL skripty pro inicializaci databáze
│   └── 01_create_tables.sql     # Definice tabulek
├── data/                        # Adresář pro vstupní data
│   └── sample_data.csv          # Vzorová data
├── tests/                       # Testy
│   ├── test_dags.py             # Testy pro Airflow DAGy
│   └── test_spark_jobs.py       # Testy pro Spark joby
├── docker-compose.yml           # Konfigurace služeb
├── Dockerfile                   # Definice Docker image
├── .env.example                 # Vzorová konfigurace prostředí
├── requirements.txt             # Python závislosti
└── README.md                    # Tato dokumentace
```

## 🧑‍💻 Vývoj

### Best Practices

- Každý DAG musí mít dokumentaci
- Implementujte retry mechanismy
- Používejte connections pro správu přístupu k databázím
- Optimalizujte Spark joby (používejte cache(), persist() s rozmyslem)

## 📝 Licence

MIT 