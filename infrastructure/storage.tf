resource "google_storage_bucket" "primary" {
  name          = "${var.gcp_project_id}-storage"
  location      = "EUR4" # dual-region
  force_destroy = "true"
  provider      = google
}

resource "google_storage_bucket_object" "collisions_dataset" {
  name   = "mapreduce/datasets/nyc-collisions/collisions.csv"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/input/collisions/${var.collisions_dataset_file}"
}

resource "google_storage_bucket_object" "zips_boroughs_dataset_dir" {
  name    = "mapreduce/datasets/zips-boroughs/"
  bucket  = google_storage_bucket.primary.name
  content = "dummy directory"
}

resource "google_storage_bucket_object" "zips_boroughs_dataset" {
  name   = "${google_storage_bucket_object.zips_boroughs_dataset_dir.name}zips-boroughs.csv"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/input/zips-boroughs/${var.zips_boroughs_dataset_file}"
}

resource "google_storage_bucket_object" "collisions_mapreduce_job_jar" {
  name   = "mapreduce/hadoop/job/collisions-mapreduce-job.jar"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/${var.mapreduce_job_jar_location}"
}

resource "google_storage_bucket_object" "collisions_mapreduce_job_output_dir" {
  name    = "mapreduce/hadoop/output/"
  bucket  = google_storage_bucket.primary.name
  content = "dummy"
}

resource "google_storage_bucket_object" "hive_job" {
  name   = "mapreduce/hive/job/job.hql"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/hive/job.sql"
}

resource "google_storage_bucket_object" "hive_job_output_dir" {
  name    = "mapreduce/hive/output/"
  bucket  = google_storage_bucket.primary.name
  content = "dummy"
}

resource "google_storage_bucket_object" "hive_hcatalog_jar" {
  name   = "mapreduce/hive/dependencies/hive-hcatalog-2.3.0.jar"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/hive/hive-hcatalog-core-2.3.0.jar"
}

resource "google_storage_bucket_object" "airflow_dag" {
  name       = "dags/dag.py"
  bucket     = replace(replace(google_composer_environment.airflow.config[0].dag_gcs_prefix, "gs://", ""), "/dags", "")
  source     = "${var.project_location}/airflow/dag.py"
  depends_on = [google_composer_environment.airflow]
}
