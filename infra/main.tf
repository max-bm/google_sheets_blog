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

resource "google_project_iam_custom_role" "sheets_access_roles" {
  role_id = "sheetsAccessRole"
  title   = "Sheets Access Role"
  permissions = [
    "bigquery.datasets.create",
  ]
}

resource "google_service_account_iam_binding" "sheets_access_permissions" {
  service_account_id = data.google_service_account.sheets_access.name
  role               = google_project_iam_custom_role.sheets_access_roles.name
  members = [
    "serviceAccount:${data.google_project.demo_project.number}@cloudbuild.gserviceaccount.com"
  ]
}

resource "google_service_account_iam_binding" "impersonate_sheets_access" {
  service_account_id = data.google_service_account.sheets_access.name
  role               = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:${data.google_project.demo_project.number}@cloudbuild.gserviceaccount.com"
  ]
}

# data "google_service_account_access_token" "gdrive" {
#   target_service_account = data.google_service_account.sheets_access.email
#   scopes = [
#     # "https://www.googleapis.com/auth/drive",
#     "https://www.googleapis.com/auth/cloud-platform",
#     # "https://www.googleapis.com/auth/userinfo.email"
#   ]
#   lifetime = "3600s"
#   depends_on = [
#     resource.google_service_account_iam_binding.sheets_access_permissions,
#     resource.google_service_account_iam_binding.impersonate_sheets_access
#   ]
# }

provider "google" {
  alias   = "impersonated"
  project = local.project_config.project_id
  #   access_token = data.google_service_account_access_token.gdrive.access_token
}
