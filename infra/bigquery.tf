# --- BUILD THE BIGQUERY DATASET AND EXTERNAL TABLE ---
# Wait for IAM permissions to propagate - 120s should be enough
# This is a workaround for some Google resources not having a built-in retry mechanism
resource "time_sleep" "wait_for_iam_propagation" {
  create_duration = "120s"
  depends_on = [
    google_project_iam_member.bigquery_data_editor,
    google_service_account_iam_member.impersonate_service_account
  ]
}

# Build the dataset with the impersonated provider
resource "google_bigquery_dataset" "dataset" {
  provider   = google.impersonated
  dataset_id = "demo_dataset"
  location   = local.vars.REGION
  depends_on = [
    time_sleep.wait_for_iam_propagation
  ]
}

# Build the external table with the impersonated provider
resource "google_bigquery_table" "table" {
  provider            = google.impersonated
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "demo_table"
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
}
