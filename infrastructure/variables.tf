variable "project_location" {
  description = "env variable that stores path of the project"
}

variable "gcp_credentials_file" {
  description = "env variable that stores path to key file"
}

variable "gcp_project_id" {
  description = "env variable that stores id of the project"
}

variable "region" {
  default = "europe-west3"
}

variable "zone" {
  default = "a"
}

variable "dataproc_mapreduce_cluster_name" {
  default = "mapreduce-cluster"
}

variable "mapreduce_job_jar_location" {
  default = "mapreduce/target/scala-2.12/collisions-mapreduce-job.jar"
}
