from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=1),
    'start_date': datetime(2025, 2, 10)
}

with DAG(
    'process_dds.py',
    default_args = default_args,
    description='Process and aggregate data into dds.olympics',
    schedule_interval=None,
    catchup=False,
    tags=['olympics']
) as dag:
    
    run_procedure = PostgresOperator(
        task_id = 'call_etl_usp_dds_olympics_insert',
        postgres_conn_id='bi_rd_lab_db',
        sql="CALL etl.usp_dds_olympics_insert();"
    )
    
    run_procedure