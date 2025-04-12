from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_timestamp, lower, concat_ws, regexp_replace
import os
import sys

def create_spark_session():
    """
    Vytvoří a vrátí SparkSession pro lokální mód s JDBC driverem
    """
    return SparkSession.builder \
        .appName("Simple ETL Process") \
        .master("local[*]") \
        .config("spark.driver.extraClassPath", "/opt/bitnami/spark/jdbc_drivers/postgresql-42.6.0.jar") \
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
    Provede transformaci dat - vytvoření username z jména a příjmení s odstraněním diakritiky
    """
    # Funkce pro odstranění diakritiky
    def remove_accents(col_name):
        # Nahrazení českých znaků s diakritikou
        transforms = [
            ("á", "a"), ("č|ć", "c"), ("ď|đ", "d"), ("é|ě|è", "e"), ("í|ì", "i"),
            ("ň", "n"), ("ó|ô", "o"), ("ř|ŕ", "r"), ("š|ś", "s"), ("ť", "t"),
            ("ú|ů|ü", "u"), ("ý", "y"), ("ž|ź", "z")
        ]
        
        result = col_name
        for pattern, replacement in transforms:
            result = regexp_replace(result, pattern, replacement)
        
        return lower(result)

    return df.select(
        "first_name",
        "last_name",
        "email",
        # Vytvoření username z first_name a last_name s odstraněním diakritiky
        lower(regexp_replace(concat_ws("_", 
            remove_accents(col("first_name")), 
            remove_accents(col("last_name"))), 
            "\\s+", "_")).alias("username"),
        current_timestamp().alias("created_at"),
        current_timestamp().alias("updated_at")
    )

def write_to_postgres(df, table_name, mode="append"):
    """
    Zapíše DataFrame do PostgreSQL databáze
    """
    jdbc_url = "jdbc:postgresql://postgres:5432/etl_db"
    properties = {
        "user": "postgres",
        "password": "postgres",
        "driver": "org.postgresql.Driver"
    }
    
    df.write \
        .jdbc(url=jdbc_url, table=table_name, mode=mode, properties=properties)

def main():
    """
    Hlavní ETL funkce
    """
    # Výchozí hodnoty
    input_path = "/opt/bitnami/spark/data/sample_data.csv"
    table_name = "users_transformed"
    
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
        
        # Zobrazení transformovaných dat
        print("Transformovaná data:")
        transformed_df.show(truncate=False)
        
        # Zápis do PostgreSQL
        write_to_postgres(transformed_df, table_name)
        
        print(f"Data byla úspěšně transformována a uložena do tabulky {table_name}")
        
    except Exception as e:
        print(f"Chyba při zpracování dat: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        # Ukončení SparkSession
        if 'spark' in locals():
            spark.stop()
        
if __name__ == "__main__":
    main() 