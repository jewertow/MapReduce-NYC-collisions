variable "gcp_credentials_file" {
  description = "env variable that stores path to key file"
}

variable "gcp_project_id" {
  description = "env variable that stores id of the project"
}

variable "region" {
  default = "europe-west4"
}

variable "zone" {
  default = "a"
}

variable "mapreduce_input_location" {
  description = "env variable that stores path of the project"
}

variable "dataproc_mapreduce_cluster_name" {
  default = "mapreduce-cluster"
}
