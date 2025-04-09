from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_timestamp, lower, concat_ws, regexp_replace

# Inicializace SparkSession
spark = SparkSession.builder \
    .appName("CSV to PostgreSQL ETL") \
    .config("spark.driver.extraClassPath", "/app/postgresql-42.2.5.jar") \
    .getOrCreate()

try:
    # Načtení CSV souboru do DataFrame
    df = spark.read.csv('/app/data/users.csv', header=True, inferSchema=True)

    # Transformace dat: přidání username, časových razítek a příprava pro import
    transformed_df = df.select(
        "first_name",
        "last_name",
        "email",
        # Vytvoření username z first_name a last_name
        lower(regexp_replace(concat_ws("_", col("first_name"), col("last_name")), "\\s+", "_")).alias("username"),
        current_timestamp().alias("created_at"),
        current_timestamp().alias("updated_at")
    )

    # Definice parametrů pro připojení k PostgreSQL
    db_properties = {
        "user": "postgres",
        "password": "postgres",
        "driver": "org.postgresql.Driver"
    }
    db_url = "jdbc:postgresql://postgres:5432/etl_db"

    # Uložení transformovaných dat do PostgreSQL
    transformed_df.write \
        .jdbc(url=db_url, 
              table="users", 
              mode="append", 
              properties=db_properties)

    print("Data byla úspěšně načtena do tabulky 'users' v PostgreSQL.")

except Exception as e:
    print(f"Chyba při zpracování dat: {str(e)}")
    raise e

finally:
    # Ukončení SparkSession
    spark.stop()