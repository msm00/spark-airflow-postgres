#!/bin/bash
set -e

# Barevné výstupy
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Aktualizace kontejnerů pro testování ===${NC}"

# Funkce pro zjištění ID kontejneru podle názvu
get_container_id() {
  local container_name=$1
  docker ps -q -f "name=$container_name"
}

# Instalace pytest v Airflow kontejneru
echo -e "${YELLOW}Instaluji pytest v Airflow kontejneru...${NC}"
AIRFLOW_CONTAINER_ID=$(get_container_id airflow-webserver)
if [ -z "$AIRFLOW_CONTAINER_ID" ]; then
  echo -e "${RED}Airflow kontejner není spuštěn!${NC}"
  exit 1
fi
docker exec -it $AIRFLOW_CONTAINER_ID bash -c "pip install pytest pytest-mock pandas --user || echo 'Pip install selhalo, zkusím jinou metodu' && python -m pip install pytest pytest-mock pandas --user"
echo -e "${GREEN}Pytest nainstalován v Airflow kontejneru${NC}"

# Instalace pytest v Spark kontejneru
echo -e "${YELLOW}Instaluji pytest v Spark kontejneru...${NC}"
SPARK_CONTAINER_ID=$(get_container_id spark)
if [ -z "$SPARK_CONTAINER_ID" ]; then
  echo -e "${RED}Spark kontejner není spuštěn!${NC}"
  exit 1
fi
docker exec -it $SPARK_CONTAINER_ID bash -c "pip install pytest pytest-mock pandas --user || python -m pip install pytest pytest-mock pandas --user"
echo -e "${GREEN}Pytest nainstalován v Spark kontejneru${NC}"

echo -e "${BLUE}=== Aktualizace dokončena ===${NC}" 