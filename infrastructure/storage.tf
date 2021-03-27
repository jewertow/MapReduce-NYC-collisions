resource "google_storage_bucket" "primary" {
  name          = "${var.gcp_project_id}-storage"
  location      = "EUR4" # dual-region
  force_destroy = "true"
  provider      = google
}

resource "google_storage_bucket_object" "collisions_mapreduce_job_jar" {
  name   = "mapreduce/jar/collisions-mapreduce-job.jar"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/${var.mapreduce_job_jar_location}"
}

resource "google_storage_bucket_object" "collisions_dataset" {
  name   = "mapreduce/input/collisions.csv"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/input/collisions/${var.collisions_dataset_file}"
}

resource "google_storage_bucket_object" "collisions_test_dataset" {
  name   = "mapreduce/input/test/collisions.csv"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/input/collisions/${var.collisions_test_dataset_file}"
}

resource "google_storage_bucket_object" "zips_boroughs_dataset" {
  name   = "mapreduce/hive/tables/zips-boroughs/zips-boroughs.csv"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/input/zips-boroughs/${var.zips_boroughs_dataset_file}"
}

resource "google_storage_bucket_object" "hive_hcatalog_jar" {
  name   = "hive/libs/hive-hcatalog-2.3.0.jar"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/libs/hive-hcatalog-core-2.3.0.jar"
}
