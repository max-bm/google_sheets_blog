variable "project_id" {
  default     = "another-blog-proj"
  type        = string
  description = "The project where the function should be deployed"
}

variable "region" {
  default     = "europe-west2"
  type        = string
  description = "Region"
}

variable "schema_file_path" {
  default     = "./config"
  type        = string
  description = "The location of the Bigquery YAML"
}

variable "service_account_id" {
  default     = "sheets-access-sa"
  type        = string
  description = "The ID of your BigQuery-Sheets Service Account"
}
