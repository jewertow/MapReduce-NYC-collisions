resource "google_storage_bucket" "google_storage_bucket_primary" {
  name          = "${var.project}-storage"
  location      = "EUR4" # dual-region
  force_destroy = "true"
}
