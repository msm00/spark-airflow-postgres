# Base image s podporou Pythonu
FROM python:3.11-slim

# Proměnné prostředí
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Systémové závislosti
RUN apt-get update && apt-get install -y \
    default-jre \
    curl \
    wget \
    git \
    procps \
    libpq-dev \
    gcc \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Nastavení JAVA_HOME pro Spark
ENV JAVA_HOME=/usr/lib/jvm/default-java
ENV PATH="$JAVA_HOME/bin:$PATH"

# Vytvoření pracovního adresáře
WORKDIR /app

# Kopírování a instalace Python závislostí
COPY requirements.txt /app/
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Kopírování Spark jobů
COPY spark_jobs/ /app/spark_jobs/

# Přidání PostgreSQL JDBC driveru pro Spark
ARG POSTGRES_JDBC_VERSION=42.6.0
RUN mkdir -p /app/lib && \
    curl -L -o /app/lib/postgresql-${POSTGRES_JDBC_VERSION}.jar \
    https://jdbc.postgresql.org/download/postgresql-${POSTGRES_JDBC_VERSION}.jar

# Nastavení Spark proměnných
ENV SPARK_CLASSPATH=/app/lib/postgresql-${POSTGRES_JDBC_VERSION}.jar

# Přidání Python cesty
ENV PYTHONPATH="${PYTHONPATH}:/app"

# Vytvoření adresáře pro data
RUN mkdir -p /app/data

# Kopírování testů
COPY tests/ /app/tests/

# Spuštění ETL procesu
CMD ["python", "/app/spark_jobs/etl_process.py"]