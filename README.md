# 🔥 Spark ETL Project

Profesionální ETL projekt pro zpracování dat pomocí Apache Spark a uložení do PostgreSQL databáze.

## 🚀 Funkce

- ⚡ ETL proces pomocí Apache Spark
- 🐘 Ukládání dat do PostgreSQL
- 🐳 Kompletní Docker prostředí
- 🧮 Transformace CSV dat
- 📊 Správa pomocí pgAdmin
- 🔄 CI/CD pipeline s GitHub Actions
- 📅 Plánování úloh pomocí Apache Airflow
- 📈 Monitoring pomocí Prometheus a Grafana
- 🧩 Kubernetes konfigurace pro orchestraci
- 🧹 Automatické čištění Docker artefaktů
- 🔐 Správa proměnných prostředí a tajných klíčů

## 📊 Architektura

Projekt se skládá z několika komponent:

1. **Spark ETL Kontejner** - Zpracovává a transformuje data z CSV souborů
2. **PostgreSQL Databáze** - Uložiště pro transformovaná data
3. **pgAdmin** - Webové rozhraní pro správu databáze
4. **Airflow** - Orchestrace a plánování ETL procesů
5. **Prometheus/Grafana** - Monitoring a vizualizace metrik
6. **Logstash** - Zpracování a analýza logů

## 🛠️ Technologie

- Apache Spark 3.5.0
- Python 3.11
- PostgreSQL
- Docker & Docker Compose
- Apache Airflow
- Prometheus & Grafana
- Kubernetes
- GitHub Actions

## ⚙️ Instalace a spuštění

### Požadavky
- Docker a Docker Compose
- Git

### Rychlé spuštění

```bash
# Klonování repozitáře
git clone https://github.com/msm00/spark-etl-project.git
cd spark-etl-project

# Spuštění pomocí skriptu (vytvoří .env soubor a spustí služby)
bash scripts/start.sh dev
```

### Manuální spuštění

```bash
# Spuštění vývojového prostředí
docker-compose up -d

# Spuštění produkčního prostředí
docker-compose -f docker-compose.prod.yml up -d

# Spuštění pouze ETL procesu
docker-compose up spark-etl
```

### Čištění Docker artefaktů

```bash
# Manuální čištění
bash scripts/docker_cleanup.sh

# Automatické čištění (nastavení v crontab)
# 0 1 * * 0 /path/to/docker_cleanup.sh
```

### Přístup k webovým rozhraním

- **pgAdmin**: http://localhost:5050
  - Email: admin@example.com
  - Heslo: admin
- **Airflow** (pouze v produkci): http://localhost:8080
- **Prometheus** (pouze v produkci): http://localhost:9090
- **Grafana** (pouze v produkci): http://localhost:3000
  - Uživatel: admin
  - Heslo: admin

## 🧪 Testování

```bash
# Spuštění jednotkových testů
python -m pytest tests/

# Spuštění testů s pokrytím
python -m pytest --cov=pyspark_etl_project tests/
```

## 📦 CI/CD Pipeline

Projekt používá GitHub Actions pro automatický:
- Lint a kontrolu kódu
- Spuštění testů
- Build a push Docker image
- Čištění starých Docker images

## 🔧 Kubernetes Deployment

Pro nasazení do Kubernetes:

```bash
kubectl apply -f kubernetes/spark-etl-job.yaml
```

## 📁 Struktura projektu

```
.
├── Dockerfile                   # Definice Docker image pro Spark ETL
├── docker-compose.yml           # Konfigurace služeb pro vývoj
├── docker-compose.prod.yml      # Konfigurace služeb pro produkci
├── .github/workflows/           # CI/CD konfigurace
│   └── ci-cd.yml
├── airflow/                     # Apache Airflow konfigurace
│   ├── dags/                    # DAG definice
│   └── plugins/                 # Airflow pluginy
├── kubernetes/                  # Kubernetes konfigurace
│   └── spark-etl-job.yaml       # Job definice
├── monitoring/                  # Monitoring konfigurace
│   ├── prometheus/              # Prometheus konfigurace
│   └── grafana/                 # Grafana dashboardy
├── scripts/                     # Pomocné skripty
│   ├── start.sh                 # Skript pro spuštění prostředí
│   └── docker_cleanup.sh        # Skript pro čištění Docker
├── data/                        # Adresář se zdrojovými daty
│   └── users.csv                # Vzorová data
├── db-init/                     # SQL skripty pro inicializaci databáze
│   └── 01_create_users_table.sql
├── pgadmin/                     # Konfigurace pgAdmin
│   ├── pgpassfile
│   └── servers.json
├── pyspark_etl_project/         # Python kód pro ETL
│   ├── __init__.py
│   └── etl.py                   # Hlavní ETL skript
└── tests/                       # Testy
    ├── __init__.py
    └── test_etl.py              # Testy pro ETL proces
```

## 📝 Licence

MIT 