data "google_project" "demo_project" {
  project_id = local.project_config.project_id
  depends_on = [
    resource.google_project_service.enable_apis
  ]
}

data "google_service_account" "sheets_access" {
  account_id = local.project_config.service_account_id
  depends_on = [
    resource.google_project_service.enable_apis
  ]
}

resource "google_service_account_iam_binding" "impersonate_sheets_access" {
  service_account_id = data.google_service_account.sheets_access.name
  role               = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:${data.google_project.demo_project.number}@cloudbuild.gserviceaccount.com"
  ]
}

data "google_service_account_access_token" "gdrive" {
  target_service_account = data.google_service_account.sheets_access.email
  scopes = [
    "https://www.googleapis.com/auth/drive",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email"
  ]
  lifetime = "300s"
  depends_on = [
    resource.google_service_account_iam_binding.impersonate_sheets_access
  ]
}

provider "google" {
  alias        = "impersonated"
  project      = local.project_config.project_id
  access_token = data.google_service_account_access_token.gdrive.access_token
}

resource "google_bigquery_table" "table" {
  for_each = local.tables

  provider            = google.impersonated
  dataset_id          = each.value.dataset_id
  table_id            = each.value.name
  deletion_protection = each.value.deletion_protection

  dynamic "external_data_configuration" {
    for_each = each.value.external_data_configuration

    content {
      autodetect    = external_data_configuration.value.autodetect
      source_format = external_data_configuration.value.source_format
      source_uris   = external_data_configuration.value.source_uris

      dynamic "google_sheets_options" {
        for_each = external_data_configuration.value.google_sheets_options

        content {
          range             = google_sheets_options.value.range
          skip_leading_rows = google_sheets_options.value.skip_leading_rows
        }
      }
    }
  }

  depends_on = [
    google_bigquery_dataset.dataset,
    data.google_service_account_access_token.gdrive
  ]
}
