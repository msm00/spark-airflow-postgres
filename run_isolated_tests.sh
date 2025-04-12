#!/bin/bash
set -e

# Barevné výstupy
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Spouštím izolované testy v Docker kontejneru ===${NC}"

# Vytvoření testovacích dat, pokud je potřeba
if [ ! -f ./data/sample_data.csv ]; then
  echo -e "${YELLOW}Vytvářím testovací data...${NC}"
  mkdir -p ./data
  echo "first_name,last_name,email" > ./data/sample_data.csv
  echo "Jan,Novák,jan.novak@email.cz" >> ./data/sample_data.csv
  echo "Marie,Svobodová,marie.svobodova@gmail.com" >> ./data/sample_data.csv
fi

# Vytvoření testovacího Docker obrazu
echo -e "${BLUE}Sestavuji testovací Docker obraz...${NC}"
docker build -t spark-airflow-test -f Dockerfile.test .

# Spuštění všech testů s generováním HTML reportu
echo -e "${BLUE}Spouštím všechny testy...${NC}"
docker run --rm \
  --name spark-airflow-test \
  -v $(pwd)/test-reports:/app/test-reports \
  -e SKIP_AIRFLOW_TESTS=1 \
  spark-airflow-test \
  bash -c "pytest -v tests/ --html=test-reports/report.html --cov=spark_jobs --cov-report=html:test-reports/coverage"

echo -e "\n${GREEN}Testy dokončeny. HTML report je dostupný v adresáři ./test-reports/report.html${NC}"
echo -e "${GREEN}Report pokrytí kódu je dostupný v adresáři ./test-reports/coverage/index.html${NC}" 