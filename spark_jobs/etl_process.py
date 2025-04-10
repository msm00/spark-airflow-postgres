from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_timestamp, lower, concat_ws, regexp_replace
import os
import sys

def create_spark_session():
    """
    Vytvoří a vrátí SparkSession s PostgreSQL JDBC driver
    """
    return SparkSession.builder \
        .appName("Spark ETL Process") \
        .config("spark.jars.packages", "org.postgresql:postgresql:42.6.0") \
        .getOrCreate()

def read_csv_data(spark, input_path):
    """
    Načte CSV soubor do Spark DataFrame
    """
    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Vstupní soubor {input_path} neexistuje")
    
    return spark.read.csv(input_path, header=True, inferSchema=True)

def transform_data(df):
    """
    Provede transformaci dat
    """
    return df.select(
        "first_name",
        "last_name",
        "email",
        # Vytvoření username z first_name a last_name
        lower(regexp_replace(concat_ws("_", col("first_name"), col("last_name")), "\\s+", "_")).alias("username"),
        current_timestamp().alias("created_at"),
        current_timestamp().alias("updated_at")
    )

def write_to_postgres(df, table_name, mode="append"):
    """
    Zapíše DataFrame do PostgreSQL databáze
    """
    # Získání proměnných prostředí nebo nastavení výchozích hodnot
    jdbc_url = f"jdbc:postgresql://{os.environ.get('POSTGRES_HOST', 'postgres')}:5432/{os.environ.get('POSTGRES_DB', 'etl_db')}"
    
    properties = {
        "user": os.environ.get("POSTGRES_USER", "postgres"),
        "password": os.environ.get("POSTGRES_PASSWORD", "postgres"),
        "driver": "org.postgresql.Driver"
    }
    
    df.write \
        .jdbc(url=jdbc_url, table=table_name, mode=mode, properties=properties)

def main():
    """
    Hlavní ETL funkce
    """
    # Výchozí hodnoty
    input_path = os.environ.get("INPUT_PATH", "/opt/bitnami/spark/data/sample_data.csv")
    table_name = os.environ.get("OUTPUT_TABLE", "users")
    
    # Zpracování argumentů příkazové řádky
    if len(sys.argv) > 1:
        input_path = sys.argv[1]
    if len(sys.argv) > 2:
        table_name = sys.argv[2]
    
    try:
        # Inicializace Spark
        spark = create_spark_session()
        
        # Načtení a transformace dat
        df = read_csv_data(spark, input_path)
        print(f"Načteno {df.count()} záznamů z {input_path}")
        
        # Transformace dat
        transformed_df = transform_data(df)
        
        # Zápis do PostgreSQL
        write_to_postgres(transformed_df, table_name)
        
        print(f"Data byla úspěšně načtena do tabulky '{table_name}' v PostgreSQL.")
        
    except Exception as e:
        print(f"Chyba při zpracování dat: {str(e)}")
        spark.stop()
        sys.exit(1)
    finally:
        # Ukončení SparkSession
        spark.stop()
        
if __name__ == "__main__":
    main() 