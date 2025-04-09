from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.operators.email_operator import EmailOperator
from airflow.models import Variable

default_args = {
    'owner': 'msm00',
    'depends_on_past': False,
    'start_date': datetime(2023, 4, 10),
    'email': ['smidmi@gmail.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'spark_etl_pipeline',
    default_args=default_args,
    description='Spark ETL procesy pro transformaci dat',
    schedule_interval='0 1 * * *',  # Každý den v 1:00 ráno
    catchup=False
) as dag:

    # Proměnné pro Docker
    docker_image = Variable.get('spark_etl_image', default_var='msm00/spark-etl-project:latest')
    postgres_host = Variable.get('postgres_host', default_var='postgres')
    postgres_db = Variable.get('postgres_db', default_var='etl_db')
    postgres_user = Variable.get('postgres_user', default_var='postgres')
    postgres_password = Variable.get('postgres_password', default_var='postgres')

    # 1. Spuštění ETL procesu v Dockeru
    run_etl = DockerOperator(
        task_id='run_etl_process',
        image=docker_image,
        api_version='auto',
        auto_remove=True,
        docker_url='unix://var/run/docker.sock',
        environment={
            'SPARK_HOME': '/opt/spark',
            'POSTGRES_HOST': postgres_host,
            'POSTGRES_DB': postgres_db,
            'POSTGRES_USER': postgres_user,
            'POSTGRES_PASSWORD': postgres_password
        },
        command='python -m pyspark_etl_project.etl',
        network_mode='bridge',
        mounts=[
            {
                'source': '/data',
                'target': '/app/data',
                'type': 'bind'
            }
        ]
    )

    # 2. Odeslání e-mailu o úspěšném zpracování
    send_success_email = EmailOperator(
        task_id='send_success_email',
        to='data-team@example.com',
        subject='ETL Pipeline Completed Successfully',
        html_content="""
        <p>ETL zpracování proběhlo úspěšně.</p>
        <p>Čas: {{ execution_date }}</p>
        <p>DAG: {{ dag.dag_id }}</p>
        """
    )

    # Definice závislostí
    run_etl >> send_success_email 