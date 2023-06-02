locals {
  sheets_roles = ["roles/bigquery.admin",
  "roles/iam.serviceAccountTokenCreator",
  "roles/iam.serviceAccountAdmin"]
}

data "google_project" "sheets_project" {
  project_id = var.project_id
}

resource "google_service_account" "bigquery" {
  account_id   = "sa-bq-${data.google_project.sheets_project.number}"
  display_name = "BQ SA"
  project      = var.project_id
}

resource "google_project_iam_member" "set-roles" {
  for_each = toset(local.sheets_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.bigquery.email}"
}


resource "google_service_account_iam_binding" "token-creator-iam" {
  service_account_id = "projects/-/serviceAccounts/${google_service_account.bigquery.email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = ["serviceAccount:${data.google_project.sheets_project.number}@cloudbuild.gserviceaccount.com"]
}


data "google_service_account_access_token" "gdrive" {
  provider               = google
  target_service_account = google_service_account.bigquery.email
  scopes = ["https://www.googleapis.com/auth/drive",
    "https://www.googleapis.com/auth/bigquery",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email"
  ]
  lifetime   = "300s"
  depends_on = [resource.google_service_account_iam_binding.token-creator-iam]
}

provider "google" {
  alias        = "impersonated"
  access_token = data.google_service_account_access_token.gdrive.access_token
  project      = var.project_id
}




resource "google_bigquery_table" "table" {
  for_each = { for tbl in local.tables : "${tbl.dataset_id}-${tbl.name}" => tbl }

  provider            = google.impersonated
  dataset_id          = each.value.dataset_id
  project             = var.project_id
  table_id            = each.value.name
  deletion_protection = each.value.deletion_protection
  schema              = try(each.value.schema_file, null) != null ? file("${var.schema_file_path}/${each.value.schema_file}") : null
  labels              = merge(local.default_labels, try(each.value.labels, {}))

  dynamic "time_partitioning" {
    for_each = try(each.value.time_partitioning, null) != null ? [each.value.time_partitioning] : []

    content {
      type  = time_partitioning.value.type
      field = try(each.value.time_partitioning.field, null)
    }
  }

  dynamic "external_data_configuration" {
    for_each = try(each.value.external_data_configuration, null) != null ? [each.value.external_data_configuration] : []

    content {
      autodetect    = try(external_data_configuration.value.autodetect, false)
      compression   = try(external_data_configuration.value.compression, "NONE")
      source_format = external_data_configuration.value.source_format
      source_uris   = external_data_configuration.value.source_uris

      dynamic "csv_options" {
        for_each = try(external_data_configuration.value.csv_options, null) != null ? [external_data_configuration.value.csv_options] : []

        content {
          quote             = try(csv_options.value.quote, "\n")
          skip_leading_rows = try(csv_options.value.skip_leading_rows, 0)
          encoding          = try(csv_options.value.encoding, "UTF-8")
          field_delimiter   = try(csv_options.value.field_delimiter, ",")
        }
      }

      dynamic "google_sheets_options" {
        for_each = try(external_data_configuration.value.google_sheets_options, null) != null ? [external_data_configuration.value.google_sheets_options] : []
        content {
          range             = try(google_sheets_options.value.range, null)
          skip_leading_rows = try(google_sheets_options.value.skip_leading_rows, null)
        }
      }
    }
  }

  depends_on = [
    google_bigquery_dataset.dataset,
    google_project_iam_member.set-roles
  ]
}
