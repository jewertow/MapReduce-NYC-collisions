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

variable "execution_date_time" {
  description = "env variable that stores UNIX timestamp"
}

variable "dataproc_mapreduce_cluster_name" {
  default = "mapreduce-cluster"
}

variable "project_location" {
  description = "env variable that stores path of the project"
}

variable "mapreduce_job_jar_location" {
  default = "mapreduce/target/scala-2.12/collisions-mapreduce-job.jar"
}

variable "mapreduce_input_location" {
  description = "env variable that stores path of the project"
}

variable "collisions_dataset_file" {
  default = "NYPD_Motor_Vehicle_Collisions.csv"
}

variable "collisions_test_dataset_file" {
  default = "NYPD_Motor_Vehicle_Collisions_test.csv"
}

variable "zips_boroughs_dataset_file" {
  default = "zips-boroughs.csv"
}
