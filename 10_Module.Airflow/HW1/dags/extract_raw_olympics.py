from airflow import DAG
from datetime import datetime, timedelta
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

import pandas as pd

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=1),
    'start_date': datetime(2025, 2, 10)
}

def load_csv_to_postgres():
    csv_file_path = '/opt/airflow/dags/input/olympics.csv'
    df = pd.read_csv(csv_file_path, skiprows=4)
    df = df.where(pd.notnull(df), None)
    
    pg_hook = PostgresHook(postgres_conn_id='bi_rd_lab_db')
    with pg_hook.get_conn() as conn:
        with conn.cursor() as cursor:
            cursor.execute("TRUNCATE TABLE raw.olympics;")
            conn.commit()
            
            for _, row in df.iterrows():
                cursor.execute("""
                    INSERT INTO raw.olympics
                    (
                        City, Edition, Sport, Discipline,
                        Athlete, NOC, Gender, Event, 
                        Event_gender, Medal
                    )
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    row['City'], 
                    row['Edition'],
                    row['Sport'],
                    row['Discipline'],
                    row['Athlete'],
                    row['NOC'],
                    row['Gender'],
                    row['Event'],
                    row['Event_gender'],
                    row['Medal']
                ))
            conn.commit()

with DAG(
    'extract_raw_olympics',
    default_args=default_args,
    description='extract data from olympics.csv and copy to db',
    schedule_interval=None,
    catchup=False,
    tags=['olympics']
) as dag:
    
    load_data = PythonOperator(
        task_id='load_csv_to_postgres',
        python_callable=load_csv_to_postgres
    )

    load_data