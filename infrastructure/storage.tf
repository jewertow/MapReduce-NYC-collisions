resource "google_storage_bucket" "google_storage_bucket_primary" {
  name          = "${var.gcp_project_id}-storage"
  location      = "EUR4" # dual-region
  force_destroy = "true"
  provider      = google
}

resource "google_storage_bucket_object" "google_storage_bucket_object_test_mapreduce_input_1" {
  name   = "mapreduce/input/test/ds1.csv"
  bucket = google_storage_bucket.google_storage_bucket_primary.name
  source = "${var.mapreduce_input_location}/datasource1/${var.mapreduce_input_ds1}_test.csv"
}

resource "google_storage_bucket_object" "google_storage_bucket_object_mapreduce_input_2" {
  name   = "mapreduce/input/datasource2.txt"
  bucket = google_storage_bucket.google_storage_bucket_primary.name
  source = "${var.mapreduce_input_location}/ds2.txt"
}
