from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from dags.util import read_secret, vault_auth
from datetime import datetime, timedelta


def vault_sample(**context):
    # first step: authenticate against vault
    client = vault_auth()
    # second step: retrieve the secret
    # NOTE: the secret name should be identical to the one in vault
    gql_endpoint = read_secret("location", client)
    data_team = read_secret("meetup", client)
    print("location :" + gql_endpoint)
    print("meetup :" + data_team)


dag = DAG(
    "vault_sample",
    description="Sample DAG to demonstrate on how to use Vault",
    schedule_interval=None,
    max_active_runs=1,
    catchup=False,
    default_args={
        "owner": "airflow",
        "depends_on_past": False,
        "start_date": datetime(2015, 1, 1),
        "email": "foo@bar.com",
        "email_on_failure": False,
        "email_on_retry": False,
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
    }
)


vault_samples = PythonOperator(
    task_id='vault_samples',
    python_callable=vault_sample,
    provide_context=True,
    dag=dag,
)
