"""
DAG pro spuštění Spark ETL procesu pomocí SparkSubmitOperator
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.models import Variable

# Výchozí argumenty pro DAG
default_args = {
    'owner': 'data_team',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email': ['data-alerts@example.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Definice DAGu
with DAG(
    'data_team_user_processing_daily',
    default_args=default_args,
    description='ETL proces pro zpracování uživatelských dat',
    schedule_interval='@daily',
    catchup=False,
    tags=['spark', 'etl', 'postgres'],
    doc_md="""
    # ETL proces pro zpracování uživatelských dat
    
    Tento DAG spouští následující kroky:
    1. Kontrola dostupnosti zdrojových dat
    2. Spuštění Spark jobu pro transformaci
    3. Validace dat v PostgreSQL
    4. Notifikace o úspěšném dokončení
    
    **Vlastník DAGu**: Data Team
    """
) as dag:
    
    # 1. Kontrola dostupnosti dat
    def check_data_availability(**kwargs):
        import os
        data_path = "/opt/airflow/data/sample_data.csv"
        if not os.path.exists(data_path):
            raise FileNotFoundError(f"Vstupní soubor {data_path} neexistuje")
        return data_path
    
    check_data = PythonOperator(
        task_id='check_data_availability',
        python_callable=check_data_availability,
    )
    
    # 2. Spuštění Spark jobu s konfigurací
    spark_job = SparkSubmitOperator(
        task_id='run_spark_etl_process',
        application='/opt/airflow/spark_jobs/etl_process.py',
        conn_id='spark_default',
        application_args=['/opt/airflow/data/sample_data.csv', 'users'],
        conf={
            'spark.master': 'spark://spark:7077',
            'spark.driver.memory': '1g',
            'spark.executor.memory': '1g',
            'spark.executor.cores': '1'
        },
        verbose=True,
    )
    
    # 3. Validace dat v PostgreSQL
    validate_data = PostgresOperator(
        task_id='validate_imported_data',
        postgres_conn_id='postgres_default',
        sql="""
        SELECT
            CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END as has_data
        FROM users
        WHERE created_at >= CURRENT_DATE;
        """,
    )
    
    # 4. Archivace dat po zpracování
    def archive_processed_data(**kwargs):
        import os
        import shutil
        from datetime import datetime
        
        source_file = "/opt/airflow/data/sample_data.csv"
        archive_dir = "/opt/airflow/data/archive"
        
        # Vytvoření archivního adresáře, pokud neexistuje
        os.makedirs(archive_dir, exist_ok=True)
        
        # Sestavení názvu archivního souboru s časovým razítkem
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        target_file = f"{archive_dir}/sample_data_{timestamp}.csv"
        
        # Archivace souboru
        shutil.copy2(source_file, target_file)
        
        return target_file
    
    archive_data = PythonOperator(
        task_id='archive_processed_data',
        python_callable=archive_processed_data,
    )
    
    # Definice toku úloh
    check_data >> spark_job >> validate_data >> archive_data 