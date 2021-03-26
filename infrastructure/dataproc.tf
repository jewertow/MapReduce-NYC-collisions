locals {
  hive_drop_old_table          = "drop table if exists collisions"
  hive_create_table_collisions = <<EOF
    create external table collisions(
      street string,
      zip_code string,
      participant string,
      injury string,
      participants_number int
    )
    row format
    delimited fields terminated by ","
    stored as textfile
    location 'gs://${google_storage_bucket.primary.name}/mapreduce/output/${var.execution_date_time}';
EOF
}

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
      "gs://${google_storage_bucket.primary.name}/mapreduce/output/${var.execution_date_time}"
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

resource "google_dataproc_job" "hive_collisions_db" {
  region = google_dataproc_cluster.mapreduce_cluster.region

  placement {
    cluster_name = google_dataproc_cluster.mapreduce_cluster.name
  }

  hive_config {
    query_list = [
      local.hive_drop_old_table,
      local.hive_create_table_collisions,
      "select * from collisions limit 10;",
      "select count(*) from collisions;",
    ]
  }

  depends_on = [
    google_dataproc_cluster.mapreduce_cluster,
    google_dataproc_job.hadoop_collisions_mapreduce_job
  ]
}
