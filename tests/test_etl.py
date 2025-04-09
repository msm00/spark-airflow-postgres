import os
import unittest
from pyspark.sql import SparkSession
from pyspark.sql.functions import col
import tempfile
import csv

# Importujeme testovaný kód
# Pro testy v izolaci bez externích závislostí budeme používat mock data

class TestETLProcess(unittest.TestCase):
    """Testy pro ETL proces."""

    @classmethod
    def setUpClass(cls):
        """Nastavení SparkSession pro testy."""
        cls.spark = SparkSession.builder \
            .appName("ETLTest") \
            .master("local[*]") \
            .getOrCreate()
        
        # Vytvoření dočasného souboru s testovacími daty
        cls.temp_dir = tempfile.TemporaryDirectory()
        cls.temp_csv = os.path.join(cls.temp_dir.name, "test_users.csv")
        
        with open(cls.temp_csv, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['id', 'first_name', 'last_name', 'email', 'gender', 'country'])
            writer.writerow(['1', 'Jan', 'Novák', 'jan.novak@example.com', 'Male', 'Czech Republic'])
            writer.writerow(['2', 'Petra', 'Svobodová', 'petra.svobodova@example.com', 'Female', 'Czech Republic'])

    @classmethod
    def tearDownClass(cls):
        """Ukončení SparkSession a vyčištění dočasných souborů."""
        cls.spark.stop()
        cls.temp_dir.cleanup()

    def test_data_loading(self):
        """Test načítání dat z CSV."""
        df = self.spark.read.csv(self.temp_csv, header=True, inferSchema=True)
        self.assertEqual(df.count(), 2)
        self.assertEqual(len(df.columns), 6)
        
    def test_username_transformation(self):
        """Test transformace dat - vytvoření username."""
        from pyspark.sql.functions import lower, concat_ws, regexp_replace
        
        # Načtení dat
        df = self.spark.read.csv(self.temp_csv, header=True, inferSchema=True)
        
        # Aplikace transformace
        transformed_df = df.select(
            "first_name",
            "last_name",
            "email",
            lower(regexp_replace(concat_ws("_", col("first_name"), col("last_name")), "\\s+", "_")).alias("username")
        )
        
        # Ověření vytvoření username
        result = transformed_df.collect()
        self.assertEqual(result[0]["username"], "jan_novák")
        self.assertEqual(result[1]["username"], "petra_svobodová")
        
    def test_data_schema(self):
        """Test schématu dat po transformaci."""
        from pyspark.sql.functions import lower, concat_ws, regexp_replace, current_timestamp
        
        # Načtení dat
        df = self.spark.read.csv(self.temp_csv, header=True, inferSchema=True)
        
        # Aplikace transformace
        transformed_df = df.select(
            "first_name",
            "last_name",
            "email",
            lower(regexp_replace(concat_ws("_", col("first_name"), col("last_name")), "\\s+", "_")).alias("username"),
            current_timestamp().alias("created_at"),
            current_timestamp().alias("updated_at")
        )
        
        # Ověření schématu
        schema = transformed_df.schema
        field_names = [field.name for field in schema.fields]
        self.assertIn("username", field_names)
        self.assertIn("created_at", field_names)
        self.assertIn("updated_at", field_names)
        
if __name__ == '__main__':
    unittest.main() 