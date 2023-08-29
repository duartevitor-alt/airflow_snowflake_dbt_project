from airflow import DAG 
from airflow.providers.microsoft.azure.transfers.local_to_wasb import LocalFilesystemToWasbOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.operators.python import PythonOperator, BranchPythonOperator
from airflow.operators.empty import EmptyOperator
from airflow.decorators import task, task_group
from airflow.models import Variable
from datetime import datetime, timedelta
from include.first_snow.cosmos_config import DBT_PROJECT_CONFIG, DBT_CONFIG
from cosmos.airflow.task_group import DbtTaskGroup
from cosmos.constants import LoadMode
from cosmos.config import ProjectConfig, RenderConfig
import os 
import requests
import json


def evaluate_usp_result(ti):
    result = ti.xcom_pull(task_ids='Snowflake.exec_snowflake_usp')[0]['USP_LOAD_MOVIES_DATA']
    print(result)
    if result:
        return "dbt_phase"
    else:
        return ["dbt_phase", "send_notify"]


def delete_local_file(ti):
    path: str = ti.xcom_pull(task_ids='check_folder')['path']
    print(f"Deleting {path}")
    os.remove(path)


with DAG(
    dag_id="moviesgeneration",
    schedule_interval=None,
    start_date=datetime(2023, 8, 3),
    catchup=False,
    default_view="graph",
    tags=["Snowflake", "Movies"],
    max_active_runs=1
) as dag:
    
    @task
    def check_folder() -> str:
        path: str = "/usr/local/airflow/outputmovies"
        if os.path.exists(path):
            print("Path to results exists")
        else:
            os.mkdir(path)
            print("Path is created")
        
        filename = f"movies_{datetime.now():%Y%m%d%H%M}.json"
        path = f"{path}/{filename}"

        return {"path":path, "filename":filename}
    

    @task(multiple_outputs=True)
    def request_info() -> dict:

        offset: int = Variable.get("OFFSSET_MOVIES", 0)

        print(f"offset value = {offset}")

        url: str = "https://streamlinewatch-streaming-guide.p.rapidapi.com/movies"

        querystring: dict = {
            "region":"US",
            "sort":"popularity",
            "sources":"netflix,hulu",
            "offset":f"{offset}",
            "limit":"10"
        }

        headers: dict = {
            "X-RapidAPI-Key": "99db2141demsh09abfc817987e36p1ab64fjsna98ec46633e2",
            "X-RapidAPI-Host": "streamlinewatch-streaming-guide.p.rapidapi.com"
        }

        response = requests.get(url, headers=headers, params=querystring)
        value_results : str = json.dumps(response.json())

        return {"value_results": value_results}
    

    @task
    def write_local_results(check_folder: dict, value_results: dict):
        path: str = check_folder["path"]
        with open(path, "w") as file:
            file.write(value_results)
        
    @task_group(group_id="Azure")
    def upload_file_to_azure():
        upload_file = LocalFilesystemToWasbOperator(
            task_id="upload_task",
            wasb_conn_id="azure_conn_id",
            file_path="{{ task_instance.xcom_pull(task_ids='check_folder')['path'] }}",
            container_name="bronze",
            blob_name="{{ task_instance.xcom_pull(task_ids='check_folder')['filename'] }}"
        )

    @task
    def update_env_var():
        offset: int = Variable.get("OFFSSET_MOVIES", 0)
        Variable.set("OFFSSET_MOVIES", f"{int(offset)+5}")

    delete_local_file = PythonOperator(
        task_id="delete_local_file",
        python_callable=delete_local_file,
        provide_context=True
    ) 

    @task_group(group_id="Snowflake")
    def snowflake_process():
        exec_snowflake_usp = SnowflakeOperator(
            task_id="exec_snowflake_usp",
            sql="CALL MANAGED_DB.MOVIES.USP_LOAD_MOVIES_DATA();",
            autocommit=True
        )

    evaluate_usp_result = BranchPythonOperator(
        task_id="evaluate_usp_result",
        python_callable=evaluate_usp_result,
        provide_context=True
    ) 

    dbt = EmptyOperator(
        task_id="dbt_phase"
    )

    send_notify = EmptyOperator(
        task_id="send_notify"
    )

    dbt_transform = DbtTaskGroup(
        group_id='transform',
        project_config=DBT_PROJECT_CONFIG,
        profile_config=DBT_CONFIG,
        render_config=RenderConfig(
            load_method=LoadMode.DBT_LS,
            select=['path:models/raw', 'path:models/silver', 'path:models/gold']
        )
    )
    

    check_folder = check_folder()
    request_info = request_info()
    write_local_results = write_local_results(check_folder, request_info["value_results"])
    updated_var = update_env_var()
    upload_file_to_azure = upload_file_to_azure()
    snowflake = snowflake_process()

    [check_folder, request_info] >> write_local_results
    write_local_results >> upload_file_to_azure >> [updated_var, delete_local_file] >> snowflake
    snowflake >> evaluate_usp_result >> [dbt, send_notify]
    dbt >> dbt_transform
