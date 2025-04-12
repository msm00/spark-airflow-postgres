#!/bin/bash
set -e

# Barevné výstupy
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Spouštím testy pro Spark-Airflow-Postgres stack ===${NC}"

# Zjistíme, jestli jsou kontejnery spuštěné
if ! docker ps | grep -q "airflow-webserver.*Up"; then
  echo -e "${YELLOW}Kontejnery nejsou spuštěny. Spouštím kontejnery...${NC}"
  docker-compose up -d
  
  # Počkáme na inicializaci kontejnerů
  echo -e "${YELLOW}Čekám na inicializaci kontejnerů...${NC}"
  sleep 10
fi

# Vytvoření testovacích dat, pokud je potřeba
if [ ! -f ./data/sample_data.csv ]; then
  echo -e "${YELLOW}Vytvářím testovací data...${NC}"
  mkdir -p ./data
  echo "first_name,last_name,email" > ./data/sample_data.csv
  echo "Jan,Novák,jan.novak@email.cz" >> ./data/sample_data.csv
  echo "Marie,Svobodová,marie.svobodova@gmail.com" >> ./data/sample_data.csv
fi

# Funkce pro výpis výsledků testu
print_test_result() {
  local test_name=$1
  local exit_code=$2
  
  if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}✓ $test_name - OK${NC}"
  else
    echo -e "${RED}✗ $test_name - FAILED${NC}"
  fi
}

# Funkce pro zjištění ID kontejneru podle názvu
get_container_id() {
  local container_name=$1
  docker ps -q -f "name=$container_name"
}

# 1. Test Spark ETL procesu
echo -e "\n${BLUE}Spouštím testy Spark ETL procesu...${NC}"
SPARK_CONTAINER_ID=$(get_container_id spark)
if [ -z "$SPARK_CONTAINER_ID" ]; then
  echo -e "${RED}Spark kontejner není spuštěn!${NC}"
  exit 1
fi
docker exec -it $SPARK_CONTAINER_ID bash -c "cd /opt/bitnami/spark && PYTHONPATH=/opt/bitnami/spark/jobs:/opt/bitnami/spark/tests pytest -v tests/test_spark_jobs.py" || true
print_test_result "Spark ETL testy" $?

# 2. Test Airflow DAGů
echo -e "\n${BLUE}Spouštím testy Airflow DAGů...${NC}"
AIRFLOW_CONTAINER_ID=$(get_container_id airflow-webserver)
if [ -z "$AIRFLOW_CONTAINER_ID" ]; then
  echo -e "${RED}Airflow kontejner není spuštěn!${NC}"
  exit 1
fi
docker exec -it $AIRFLOW_CONTAINER_ID bash -c "PYTHONPATH=/opt/airflow pytest -v tests/test_dags.py" || true
print_test_result "Airflow DAG testy" $?

# 3. Integrační testy ETL procesu
echo -e "\n${BLUE}Spouštím integrační testy ETL procesu...${NC}"
docker exec -it $AIRFLOW_CONTAINER_ID bash -c "PYTHONPATH=/opt/airflow pytest -v tests/test_etl.py" || true
print_test_result "Integrační ETL testy" $?

echo -e "\n${BLUE}=== Testování dokončeno ===${NC}" 