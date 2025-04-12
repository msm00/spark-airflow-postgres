.PHONY: start stop restart status test test-isolated lint docker-build clean logs update-containers help

# Standardní příkazy
help:
	@echo "Dostupné příkazy:"
	@echo "  make start        - Spustí všechny kontejnery"
	@echo "  make stop         - Zastaví všechny kontejnery"
	@echo "  make restart      - Restartuje všechny kontejnery"
	@echo "  make status       - Zobrazí stav kontejnerů"
	@echo "  make logs         - Zobrazí logy všech kontejnerů"
	@echo "  make test         - Spustí testy v běžících kontejnerech"
	@echo "  make test-isolated - Spustí testy v izolovaném prostředí"
	@echo "  make update-containers - Aktualizuje kontejnery pro testování"
	@echo "  make lint         - Spustí kontrolu kódu pomocí pylint"
	@echo "  make docker-build - Sestaví všechny Docker image"
	@echo "  make clean        - Vyčistí dočasné soubory a zastaví kontejnery"

start:
	docker-compose up -d
	@echo "Kontejnery byly spuštěny, airflow webové rozhraní je dostupné na http://localhost:8080"
	@echo "PgAdmin je dostupný na http://localhost:5050"
	@echo "Spark UI je dostupný na http://localhost:8090"

stop:
	docker-compose down

restart: stop start

status:
	docker-compose ps

logs:
	docker-compose logs -f

test:
	./run_tests.sh

update-containers:
	./update_containers.sh

test-isolated:
	./run_isolated_tests.sh

lint:
	docker run --rm \
		-v $(PWD):/app \
		-w /app \
		python:3.11-slim \
		bash -c "pip install pylint && pylint spark_jobs/ tests/"

docker-build:
	docker-compose build
	docker build -t spark-airflow-test -f Dockerfile.test .

clean:
	docker-compose down -v
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf test-reports
	find . -name "*.pyc" -delete 