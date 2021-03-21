variable "gcp_credentials_file" {
  description = "env variable that stores path to key file"
}

variable "project" {
  description = "env variable that stores id of the project"
}

variable "region" {
  default = "europe-west4"
}

variable "zone" {
  default = "a"
}
