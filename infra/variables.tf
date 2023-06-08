variable "project_id" {
  default     = local.project_config.project_id
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
  default     = local.project_config.sheets_access_service_account_id
  type        = string
  description = "The ID of your BigQuery-Sheets Service Account"
}
