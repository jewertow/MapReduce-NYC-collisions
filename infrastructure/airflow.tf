resource "google_composer_environment" "airflow" {
  name = "airflow"
  region = var.region

  config {
    node_count = 3

    node_config {
      zone = "${var.region}-${var.zone}"
      disk_size_gb = 50
    }

    software_config {
      env_variables = {
        AIRFLOW_VAR_GCP_PROJECT = var.gcp_project_id
        AIRFLOW_VAR_GCS_BUCKET = google_storage_bucket.primary.name
        AIRFLOW_VAR_GCE_ZONE = "${var.region}-${var.zone}"
        AIRFLOW_VAR_MACHINE_TYPE = "n1-standard-2"
        AIRFLOW_VAR_MAPREDUCE_JAR = "gs://${google_storage_bucket.primary.name}/${google_storage_bucket_object.collisions_mapreduce_job_jar.name}"
      }
    }
  }
}

output "airflow_uri" {
  value = google_composer_environment.airflow.config[0].airflow_uri
}
