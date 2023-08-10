# --- CONFIGURE THE IMPERSONATED PROVIDER ---
# Grant the BigQuery Data Editor role to the target service account
resource "google_project_iam_member" "bigquery_data_editor" {
  project = local.vars.PROJECT_ID
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${data.google_service_account.service_account.email}"
}

# Grant impersonation permissions to the Cloud Build service account
resource "google_service_account_iam_member" "impersonate_service_account" {
  service_account_id = data.google_service_account.service_account.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${data.google_project.demo_project.number}@cloudbuild.gserviceaccount.com"
}

# Wait for IAM permissions to propagate - 120s should be enough
# This is a workaround for Google data sources not having a built-in retry mechanism
resource "time_sleep" "wait_for_iam_propagation" {
  create_duration = "120s"
  depends_on = [
    google_project_iam_member.bigquery_data_editor,
    google_service_account_iam_member.impersonate_service_account
  ]
}

# Create an access token to impersonate with additional scopes
data "google_service_account_access_token" "gdrive" {
  target_service_account = data.google_service_account.service_account.email
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/drive"
  ]
  lifetime   = "3600s"
  depends_on = [resource.time_sleep.wait_for_iam_propagation]
}

# Confgure the impersonated provider
provider "google" {
  alias        = "impersonated"
  project      = local.vars.PROJECT_ID
  access_token = data.google_service_account_access_token.gdrive.access_token
}
