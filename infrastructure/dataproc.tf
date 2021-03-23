resource "google_dataproc_cluster" "google_dataproc_cluster_mapreduce_cluster" {
  name     = var.dataproc_mapreduce_cluster_name
  region   = var.region
  project  = var.gcp_project_id
  provider = google-beta

  cluster_config {
    staging_bucket = google_storage_bucket.primary.name

    gce_cluster_config {
      zone = "${var.region}-${var.zone}"
    }

    endpoint_config {
      enable_http_port_access = true
    }

    master_config {
      machine_type = "n1-standard-2"
      disk_config {
        boot_disk_size_gb = 50
      }
    }

    worker_config {
      machine_type = "n1-standard-2"
      disk_config {
        boot_disk_size_gb = 50
      }
    }

    software_config {
      image_version       = "1.5-debian10"
      optional_components = ["ZEPPELIN"]
    }
  }
}
