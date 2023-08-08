# --- BUILD THE BIGQUERY DATASET AND EXTERNAL TABLE ---
# Build the dataset with the impersonated provider
resource "google_bigquery_dataset" "dataset" {
  provider   = google.impersonated
  dataset_id = "demo_dataset"
  location   = local.vars.REGION
  depends_on = [
    google_project_service.enable_apis
  ]
}

# Build the external table with the impersonated provider
resource "google_bigquery_table" "table" {
  provider            = google.impersonated
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "demo_table_terraform"
  deletion_protection = false
  external_data_configuration {
    autodetect    = true
    source_format = "GOOGLE_SHEETS"
    source_uris   = [local.vars.SHEETS_SOURCE_URI]
    google_sheets_options {
      range             = local.vars.SHEETS_RANGE
      skip_leading_rows = local.vars.SKIP_LEADING_ROWS
    }
  }
  depends_on = [
    google_bigquery_dataset.dataset
  ]
}
