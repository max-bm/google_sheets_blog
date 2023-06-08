variable "project_id" {
  default     = local.project_config.project_id
  type        = string
  description = "The project where the function should be deployed"
}

variable "region" {
  default     = local.project_config.region
  type        = string
  description = "Region"
}

variable "service_account_id" {
  default     = local.project_config.service_account_id
  type        = string
  description = "The ID of your BigQuery-Sheets Service Account"
}

variable "schema_file_path" {
  default     = "./config"
  type        = string
  description = "The location of the Bigquery YAML"
}
