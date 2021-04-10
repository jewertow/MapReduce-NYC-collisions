resource "google_composer_environment" "airflow" {
  name   = "airflow"
  region = var.region

  config {
    node_count = 3

    node_config {
      zone         = "${var.region}-${var.zone}"
      disk_size_gb = 50
    }

    software_config {
      env_variables = {
        AIRFLOW_VAR_GCP_PROJECT              = var.gcp_project_id
        AIRFLOW_VAR_GCS_BUCKET               = google_storage_bucket.primary.name
        AIRFLOW_VAR_GCE_ZONE                 = "${var.region}-${var.zone}"
        AIRFLOW_VAR_MACHINE_TYPE             = "n1-standard-2"
        AIRFLOW_VAR_HADOOP_JOB_JAR_URI       = "gs://${google_storage_bucket_object.collisions_mapreduce_job_jar.bucket}/${google_storage_bucket_object.collisions_mapreduce_job_jar.name}"
        AIRFLOW_VAR_HIVE_JOB_HQL_URI         = "gs://${google_storage_bucket_object.hive_job.bucket}/${google_storage_bucket_object.hive_job.name}"
        AIRFLOW_VAR_HADOOP_JOB_OUTPUT_BUCKET = "gs://${google_storage_bucket_object.collisions_mapreduce_job_output_dir.bucket}/${google_storage_bucket_object.collisions_mapreduce_job_output_dir.name}"
        AIRFLOW_VAR_HIVE_JOB_OUTPUT_BUCKET   = "gs://${google_storage_bucket_object.hive_job_output_dir.bucket}/${google_storage_bucket_object.hive_job_output_dir.name}"
        AIRFLOW_VAR_COLLISIONS_DATASET_URI   = "gs://${google_storage_bucket_object.collisions_dataset.bucket}/${google_storage_bucket_object.collisions_dataset.name}"
        AIRFLOW_VAR_ZIPS_BOROUGHS_BUCKET_URI = "gs://${google_storage_bucket_object.zips_boroughs_dataset_dir.bucket}/${google_storage_bucket_object.zips_boroughs_dataset_dir.name}"
        AIRFLOW_VAR_HIVE_HCATALOG_JAR_URI    = "gs://${google_storage_bucket_object.hive_hcatalog_jar.bucket}/${google_storage_bucket_object.hive_hcatalog_jar.name}"
      }
    }
  }
}

output "airflow_uri" {
  value = google_composer_environment.airflow.config[0].airflow_uri
}
