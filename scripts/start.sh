#!/bin/bash
#
# Skript pro spuštění celého ETL prostředí
#

# Načtení proměnných prostředí
if [ -f .env ]; then
    echo "Načítám proměnné prostředí z .env souboru..."
    source .env
else
    echo "Soubor .env nenalezen. Použiji výchozí hodnoty."
    # Vytvoření souboru .env ze vzoru
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "Vytvořen soubor .env z .env.example. Upravte prosím hodnoty podle potřeby."
        exit 1
    else
        echo "VAROVÁNÍ: Nenalezen ani soubor .env.example. Používám výchozí hodnoty."
    fi
fi

# Výběr prostředí
if [ -z "$1" ]; then
    echo "Vyberte prostředí (dev/prod):"
    read ENVIRONMENT
else
    ENVIRONMENT=$1
fi

# Kontrola, jestli je Docker spuštěn
if ! docker info > /dev/null 2>&1; then
    echo "Docker není spuštěn. Spusťte prosím Docker a zkuste to znovu."
    exit 1
fi

# Vytvoření potřebných adresářů
mkdir -p data
mkdir -p airflow/dags
mkdir -p airflow/logs
mkdir -p airflow/plugins
mkdir -p monitoring/prometheus
mkdir -p monitoring/grafana/provisioning
mkdir -p monitoring/logstash/pipeline
mkdir -p monitoring/logstash/config

# Podle prostředí spustíme odpovídající konfiguraci
case "$ENVIRONMENT" in
    "dev")
        echo "Spouštím vývojové prostředí..."
        docker-compose up -d
        ;;
    "prod")
        echo "Spouštím produkční prostředí..."
        docker-compose -f docker-compose.prod.yml up -d
        ;;
    *)
        echo "Neplatné prostředí. Použijte 'dev' nebo 'prod'."
        exit 1
        ;;
esac

# Kontrola, jestli jsou služby spuštěny
echo "Kontroluji spuštěné služby..."
sleep 5
docker-compose ps

echo ""
echo "=== Přehled dostupných služeb ==="
echo "PostgreSQL: localhost:${POSTGRES_PORT:-5433}"
echo "PgAdmin: http://localhost:${PGADMIN_PORT:-5050}"
if [ "$ENVIRONMENT" == "prod" ]; then
    echo "Airflow: http://localhost:8080"
    echo "Prometheus: http://localhost:9090"
    echo "Grafana: http://localhost:3000"
fi
echo "==================================="

echo ""
echo "Pro spuštění ETL procesu použijte:"
echo "docker-compose up spark-etl"

exit 0 