provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}
