import datetime
import os

from airflow import models
from airflow.contrib.operators import dataproc_operator
from airflow.utils import trigger_rule

# cluster data
project_id = models.Variable.get('gcp_project')
gcs_bucket = models.Variable.get('gcs_bucket')
gce_zone = models.Variable.get('gce_zone')
machine_type = models.Variable.get('machine_type')

# job URIs
hadoop_job_jar_uri = models.Variable.get('hadoop_job_jar_uri')
hive_job_hql_uri = models.Variable.get('hive_job_hql_uri')

# job output buckets
hadoop_job_output_bucket = models.Variable.get('hadoop_job_output_bucket')
hive_job_output_bucket = models.Variable.get('hive_job_output_bucket')

# datasets
collisions_dataset_uri = models.Variable.get('collisions_dataset_uri')
zips_boroughs_bucket_uri = models.Variable.get('zips_boroughs_bucket_uri')

# dependencies
hive_hcatalog_jar_uri = models.Variable.get('hive_hcatalog_jar_uri')

exec_dt = datetime.datetime.now().strftime('%Y%m%d')
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

    hadoop_job = dataproc_operator.DataProcHadoopOperator(
        task_id='hadoop_job',
        cluster_name=mapreduce_cluster_name,
        main_jar=hadoop_job_jar_uri,
        arguments=[
            collisions_dataset_uri,
            f'{hadoop_job_output_bucket}/{exec_dt}'
        ])

    hive_job = dataproc_operator.DataProcHiveOperator(
        task_id='hive_job',
        cluster_name=mapreduce_cluster_name,
        dataproc_hive_jars=[hive_hcatalog_jar_uri],
        query_uri=hive_job_hql_uri,
        variables={
            'collisions_job_output_bucket': f'{hadoop_job_output_bucket}/{exec_dt}',
            'hive_job_output_bucket':       f'{hive_job_output_bucket}/{exec_dt}',
            'hive_hcatalog_jar':            hive_hcatalog_jar_uri,
            'zips_boroughs_bucket':         zips_boroughs_bucket_uri
        }
    )

    delete_dataproc_cluster = dataproc_operator.DataprocClusterDeleteOperator(
        task_id='delete_dataproc_cluster',
        cluster_name=mapreduce_cluster_name,
        trigger_rule=trigger_rule.TriggerRule.ALL_DONE)

    create_dataproc_cluster >> hadoop_job >> hive_job >> delete_dataproc_cluster
