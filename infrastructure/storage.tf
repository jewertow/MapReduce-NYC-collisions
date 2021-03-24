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

resource "google_storage_bucket_object" "mapreduce_test_input_1" {
  name   = "mapreduce/input/test/ds1.csv"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/input/datasource1/${var.mapreduce_input_ds1}_test.csv"
}

resource "google_storage_bucket_object" "mapreduce_test_input_2" {
  name   = "mapreduce/input/datasource2.txt"
  bucket = google_storage_bucket.primary.name
  source = "${var.project_location}/input/ds2.txt"
}
