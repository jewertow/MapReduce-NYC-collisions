locals {
  collisions_job_jar_bucket    = "gs://${google_storage_bucket.primary.name}/${google_storage_bucket_object.collisions_mapreduce_job_jar.name}"
  collisions_job_input_bucket  = "gs://${google_storage_bucket.primary.name}/${google_storage_bucket_object.collisions_dataset.name}"
  collisions_job_output_bucket = "gs://${google_storage_bucket.primary.name}/mapreduce/output/${var.execution_date_time}"
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
    location '${local.collisions_job_output_bucket}';
EOF
  zips_boroughs_bucket = "gs://${google_storage_bucket.primary.name}/mapreduce/hive/tables/zips-boroughs"
  hive_create_table_zips_boroughs = <<EOF
    create external table zips_boroughs(
      zip_code int,
      boroughs string
    )
    row format
    delimited fields terminated by ","
    stored as textfile
    location '${local.zips_boroughs_bucket}'
    tblproperties("skip.header.line.count"="1");
EOF
  hive_join_collisions_and_zip_boroughs = <<EOF
    insert overwrite table hive_job_result
      select c.street, c.person_type, max(c.killed) as killed, max(c.injured) as injured
        from (
          select c.street, c.participant as person_type,
            case when c.injury = 'killed' then sum(c.participants_number) else 0 end as killed,
            case when c.injury = 'injured' then sum(c.participants_number) else 0 end as injured
            from collisions c
            join (
              select distinct c.street, c.zip_code
                from collisions c
                join (
                  select c.street, sum(c.participants_number) as participants
                    from collisions c
                    join zips_boroughs z
                    on c.zip_code = z.zip_code
                    where z.boroughs = "MANHATTAN"
                    group by c.street
                    order by participants desc
                    limit 3
                ) t
                on c.street = t.street
            ) t
            on c.street = t.street and c.zip_code = t.zip_code
            join zips_boroughs z
            on c.zip_code = z.zip_code
            where z.boroughs = "MANHATTAN"
            group by c.street, c.participant, c.injury
        ) c
      group by c.street, c.person_type;
EOF
  hive_job_output_bucket = "gs://${google_storage_bucket.primary.name}/hive/output/${var.execution_date_time}"
  hive_job_output_table = <<EOF
    create external table hive_job_result(
      street      string,
      person_type string,
      killed      int,
      injured     int
    )
    row format serde 'org.apache.hive.hcatalog.data.JsonSerDe'
    stored as textfile
    location '${local.hive_job_output_bucket}';
EOF
  avro_table = <<EOF
    CREATE external TABLE collisions_avro
      ROW FORMAT
      SERDE 'org.apache.hadoop.hive.serde2.avro.AvroSerDe'
      STORED AS
      INPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerInputFormat'
      OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerOutputFormat'
      location 'gs://put-big-data-2021-02-je-storage/mapreduce/output/2021-03-28-03-51-30'
      TBLPROPERTIES ('avro.schema.literal'='{
        "name": "Collisions",
        "type": "record",
        "fields": [
          {"name":"street","type":"string"},
          {"name":"zip_code","type":"string"},
          {"name":"person_type","type":"string"},
          {"name":"injury_type","type":"string"},
          {"name":"participants_number","type":"int"}
        ]
      }');
EOF
  hive_join_collisions_and_zip_boroughs_avro = <<EOF
      insert overwrite table avro_table
      select c.street, c.person_type, max(c.killed) as killed, max(c.injured) as injured
        from (
          select c.street, c.participant as person_type,
            case when c.injury = 'killed' then sum(c.participants_number) else 0 end as killed,
            case when c.injury = 'injured' then sum(c.participants_number) else 0 end as injured
            from collisions c
            join (
              select distinct c.street, c.zip_code
                from collisions c
                join (
                  select c.street, sum(c.participants_number) as participants
                    from collisions c
                    join zips_boroughs z
                    on c.zip_code = z.zip_code
                    where z.boroughs = "MANHATTAN"
                    group by c.street
                    order by participants desc
                    limit 3
                ) t
                on c.street = t.street
            ) t
            on c.street = t.street and c.zip_code = t.zip_code
            join zips_boroughs z
            on c.zip_code = z.zip_code
            where z.boroughs = "MANHATTAN"
            group by c.street, c.participant, c.injury
        ) c
      group by c.street, c.person_type;
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
    main_jar_file_uri = local.collisions_job_jar_bucket
    args = [
      local.collisions_job_input_bucket,
      local.collisions_job_output_bucket
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

resource "google_dataproc_job" "hive_job" {
  region = google_dataproc_cluster.mapreduce_cluster.region

  placement {
    cluster_name = google_dataproc_cluster.mapreduce_cluster.name
  }

  hive_config {
    jar_file_uris = [
      "gs://${google_storage_bucket.primary.name}/${google_storage_bucket_object.hive_hcatalog_jar.name}"
    ]
    query_list = [
      // collisions
      "drop table if exists collisions;",
      local.hive_create_table_collisions,
      "select * from collisions limit 10;",
      "select count(*) from collisions;",
      // zips_boroughs
      "drop table if exists zips_boroughs;",
      local.hive_create_table_zips_boroughs,
      "select * from zips_boroughs limit 10;",
      "select count(*) from zips_boroughs;",
      // hive job
      "add jar gs://${google_storage_bucket.primary.name}/${google_storage_bucket_object.hive_hcatalog_jar.name};",
      "drop table if exists hive_job_result;",
      local.hive_job_output_table,
      local.hive_join_collisions_and_zip_boroughs,
      "select * from hive_job_result;"
    ]
  }

  depends_on = [
    google_dataproc_cluster.mapreduce_cluster,
    google_dataproc_job.hadoop_collisions_mapreduce_job
  ]
}

output "hive_collisions_db_job_status" {
  value = google_dataproc_job.hive_job.status[0].state
}
