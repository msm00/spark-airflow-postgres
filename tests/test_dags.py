"""
Jednotkové testy pro Airflow DAGy
"""
import pytest
from airflow.models import DagBag

class TestDags:
    """Testy pro Airflow DAGy"""
    
    @pytest.fixture
    def dagbag(self):
        """Fixture pro načtení DAGů"""
        return DagBag(dag_folder='airflow/dags', include_examples=False)
    
    def test_dag_loading(self, dagbag):
        """Test, že všechny DAGy se načítají bez chyb"""
        assert len(dagbag.import_errors) == 0, f"Chyby při načítání DAGů: {dagbag.import_errors}"
    
    def test_dag_user_processing_exists(self, dagbag):
        """Test, že DAG pro zpracování uživatelů existuje"""
        dag = dagbag.get_dag('data_team_user_processing_daily')
        assert dag is not None
    
    def test_dag_dependencies(self, dagbag):
        """Test, že DAG má správnou strukturu závislostí"""
        dag = dagbag.get_dag('data_team_user_processing_daily')
        
        # Ověření, že jsou všechny důležité tasky přítomny
        task_ids = [task.task_id for task in dag.tasks]
        expected_task_ids = [
            'check_data_availability',
            'run_spark_etl_process',
            'validate_imported_data',
            'archive_processed_data'
        ]
        
        for task_id in expected_task_ids:
            assert task_id in task_ids, f"Task {task_id} chybí v DAGu"
        
        # Ověření závislostí
        check_task = dag.get_task('check_data_availability')
        spark_task = dag.get_task('run_spark_etl_process')
        validate_task = dag.get_task('validate_imported_data')
        archive_task = dag.get_task('archive_processed_data')
        
        # Získání downstream tasků pro každý task
        check_downstream = check_task.downstream_task_ids
        spark_downstream = spark_task.downstream_task_ids
        validate_downstream = validate_task.downstream_task_ids
        
        # Ověření závislostí
        assert 'run_spark_etl_process' in check_downstream
        assert 'validate_imported_data' in spark_downstream
        assert 'archive_processed_data' in validate_downstream 