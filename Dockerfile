# 🐍 Základní image s podporou Pythonu
FROM python:3.11-slim

# 📦 Základní systémové balíčky (pro Spark a Poetry)
RUN apt-get update && apt-get install -y \
    default-jre \
    curl \
    wget \
    gnupg \
    git \
    && apt-get clean

# 🌍 Nastavení JAVA_HOME, které Spark vyžaduje
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
ENV PATH="$JAVA_HOME/bin:$PATH"

# 🔥 Instalace Apache Spark (verze 3.5.0 jako příklad)
ENV SPARK_VERSION=3.5.0
RUN curl -L https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz | \
    tar -xz -C /opt/ && \
    ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop3 /opt/spark

# ✳️ Nastavení Spark proměnných
ENV SPARK_HOME=/opt/spark
ENV PATH="$SPARK_HOME/bin:$PATH"

# 📥 Stažení PostgreSQL JDBC driveru
RUN mkdir -p /app && \
    curl -L -o /app/postgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar

# 🐍 Instalace Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# ✳️ Přidání Poetry do PATH
ENV PATH="/root/.local/bin:$PATH"

# 📂 Pracovní adresář v kontejneru
WORKDIR /app

# 🗂️ Zkopírování celého projektu
COPY . /app/

# 📦 Instalace Python závislostí pomocí Poetry
RUN pip install --upgrade pip wheel setuptools && \
    if [ -f /app/pyproject.toml ]; then \
    poetry config virtualenvs.create false && poetry install --no-root; \
    else \
    pip install pyspark psycopg2-binary; \
    fi

# 🟡 Nastavení vstupního bodu
CMD ["python", "-m", "pyspark_etl_project.etl"]