resource "google_dataproc_cluster" "mapreduce_cluster" {
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

resource "google_dataproc_job" "hadoop_collisions_mapreduce_job" {
  region = google_dataproc_cluster.mapreduce_cluster.region

  placement {
    cluster_name = google_dataproc_cluster.mapreduce_cluster.name
  }

  hadoop_config {
    main_jar_file_uri = "gs://${google_storage_bucket.primary.name}/${google_storage_bucket_object.collisions_mapreduce_job_jar.name}"
    args = [
      "gs://${google_storage_bucket.primary.name}/${google_storage_bucket_object.collisions_dataset.name}",
      "gs://${google_storage_bucket.primary.name}/mapreduce/output/${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
    ]
  }

  depends_on = [
    google_dataproc_cluster.mapreduce_cluster,
    google_storage_bucket_object.collisions_mapreduce_job_jar,
    google_storage_bucket_object.collisions_dataset
  ]
}

output "hadoop_collisions_mapreduce_job_status" {
  value = google_dataproc_job.hadoop_collisions_mapreduce_job.status[0].state
}
