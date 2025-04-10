"""
Jednotkové testy pro Spark ETL procesy
"""
import os
import sys
import pytest
import pandas as pd
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, TimestampType

# Přidání spark_jobs do Python path pro import
sys.path.append(os.path.join(os.path.dirname(os.path.dirname(__file__)), 'spark_jobs'))
from etl_process import create_spark_session, transform_data

class TestSparkJobs:
    """Testy pro Spark ETL procesy"""
    
    @pytest.fixture(scope="module")
    def spark(self):
        """Vytvoří a vrátí SparkSession pro testy"""
        spark = SparkSession.builder \
            .appName("Spark ETL Test") \
            .master("local[1]") \
            .getOrCreate()
        yield spark
        spark.stop()
    
    @pytest.fixture
    def sample_data(self, spark):
        """Vytvoří testovací DataFrame"""
        data = [
            ("Jan", "Novák", "jan.novak@email.cz"),
            ("Marie", "Svobodová", "marie.svobodova@gmail.com")
        ]
        schema = StructType([
            StructField("first_name", StringType(), True),
            StructField("last_name", StringType(), True),
            StructField("email", StringType(), True)
        ])
        return spark.createDataFrame(data, schema)
    
    def test_create_spark_session(self):
        """Test, že SparkSession se správně vytvoří"""
        spark = create_spark_session()
        assert spark is not None
        assert spark.version is not None
        spark.stop()
    
    def test_transform_data(self, spark, sample_data):
        """Test transformační funkce"""
        # Provedení transformace
        result_df = transform_data(sample_data)
        
        # Převod na Pandas pro jednodušší testování
        result_pd = result_df.toPandas()
        
        # Kontrola výsledku
        assert len(result_pd) == 2
        assert "username" in result_pd.columns
        assert "created_at" in result_pd.columns
        assert "updated_at" in result_pd.columns
        
        # Kontrola transformace jmen na username
        assert result_pd.loc[0, "username"] == "jan_novak"
        assert result_pd.loc[1, "username"] == "marie_svobodova"
    
    def test_transform_data_with_empty_input(self, spark):
        """Test transformace s prázdným vstupem"""
        # Vytvoření prázdného DataFrame
        empty_df = spark.createDataFrame([], schema=StructType([
            StructField("first_name", StringType(), True),
            StructField("last_name", StringType(), True),
            StructField("email", StringType(), True)
        ]))
        
        # Provedení transformace
        result_df = transform_data(empty_df)
        
        # Kontrola výsledku
        assert result_df.count() == 0 