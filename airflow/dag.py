import datetime
import os

from airflow import models
from airflow.contrib.operators import dataproc_operator
from airflow.utils import trigger_rule

project_id = models.Variable.get('gcp_project')
gcs_bucket = models.Variable.get('gcs_bucket')
gce_zone = models.Variable.get('gce_zone')
machine_type = models.Variable.get('machine_type')
mapreduce_jar = models.Variable.get('mapreduce_jar')

exec_dt = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
mapreduce_hadoop_job_args = [
    f'gs://{gcs_bucket}/mapreduce/input/collisions.csv',
    f'gs://{gcs_bucket}/mapreduce/output/{exec_dt}/'
]

yesterday = datetime.datetime.combine(
    datetime.datetime.today() - datetime.timedelta(1),
    datetime.datetime.min.time())

default_dag_args = {
    'start_date': yesterday,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': datetime.timedelta(minutes=5),
    'project_id': project_id
}

with models.DAG(
        'nyc_collisions_dag',
        schedule_interval=datetime.timedelta(days=1),
        default_args=default_dag_args) as dag:

    mapreduce_cluster_name = 'airflow-mapreduce-cluster'

    create_dataproc_cluster = dataproc_operator.DataprocClusterCreateOperator(
        task_id='create_dataproc_cluster',
        cluster_name=mapreduce_cluster_name,
        num_workers=2,
        zone=gce_zone,
        master_machine_type=machine_type,
        worker_machine_type=machine_type)

    run_dataproc_hadoop_job = dataproc_operator.DataProcHadoopOperator(
        task_id='run_dataproc_hadoop_job',
        main_jar=mapreduce_jar,
        cluster_name=mapreduce_cluster_name,
        arguments=mapreduce_hadoop_job_args)

    delete_dataproc_cluster = dataproc_operator.DataprocClusterDeleteOperator(
        task_id='delete_dataproc_cluster',
        cluster_name=mapreduce_cluster_name,
        trigger_rule=trigger_rule.TriggerRule.ALL_DONE)

    create_dataproc_cluster >> run_dataproc_hadoop_job >> delete_dataproc_cluster
