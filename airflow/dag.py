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

exec_dt = datetime.datetime.now().strftime('%Y%m%d')
mapreduce_hadoop_job_args = [
    f'gs://{gcs_bucket}/mapreduce/input/collisions.csv',
    f'gs://{gcs_bucket}/mapreduce/output/{exec_dt}'
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
        cluster_name=mapreduce_cluster_name,
        main_jar=mapreduce_jar,
        arguments=mapreduce_hadoop_job_args)

    run_dataproc_hive_job = dataproc_operator.DataProcHiveOperator(
        task_id='run_dataproc_hive_job',
        cluster_name=mapreduce_cluster_name,
        dataproc_hive_jars=[f"gs://{gcs_bucket}/hive/libs/hive-hcatalog-2.3.0.jar"],
        query_uri=f"gs://{gcs_bucket}/hive/job/job.hql",
        variables={
            'collisions_job_output_bucket': f'gs://{gcs_bucket}/mapreduce/output/{exec_dt}',
            'zips_boroughs_bucket':         f'gs://{gcs_bucket}/mapreduce/hive/tables/zips-boroughs',
            'hive_job_output_bucket':       f'gs://{gcs_bucket}/mapreduce/hive/output/{exec_dt}',
            'hive_hcatalog_jar':            f'gs://{gcs_bucket}/hive/libs/hive-hcatalog-2.3.0.jar'
        }
    )

    delete_dataproc_cluster = dataproc_operator.DataprocClusterDeleteOperator(
        task_id='delete_dataproc_cluster',
        cluster_name=mapreduce_cluster_name,
        trigger_rule=trigger_rule.TriggerRule.ALL_DONE)

    create_dataproc_cluster >> run_dataproc_hadoop_job >> run_dataproc_hive_job >> delete_dataproc_cluster
