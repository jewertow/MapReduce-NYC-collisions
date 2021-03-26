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

resource "google_storage_bucket_object" "mapreduce_test_input_2" {
  name   = "mapreduce/input/datasource2.txt"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/input/ds2.txt"
}
