resource "google_bigquery_dataset" "dataset" {
  for_each = local.datasets

  provider   = google.impersonated
  dataset_id = each.key
  location   = local.project_config.region

  depends_on = [
    google_project_service.enable_apis,
    data.google_service_account_access_token.gdrive
  ]
}
