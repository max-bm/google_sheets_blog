# --- SETUP ---
# Read configuration variables from config.env
locals {
  vars = {
    for tuple in regexall("(.*)=(.*)", file("../config.env")) : tuple[0] => tuple[1]
  }
}

# Configure the base provider
provider "google" {
  project = local.vars.PROJECT_ID
  region  = local.vars.REGION
}

# Enable the required APIs
resource "google_project_service" "enable_apis" {
  for_each = toset([
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])
  project            = local.vars.PROJECT_ID
  service            = each.key
  disable_on_destroy = false
}

# Reference to the Google Cloud project
data "google_project" "demo_project" {
  project_id = local.vars.PROJECT_ID
  depends_on = [
    resource.google_project_service.enable_apis
  ]
}

# Reference to the service account with access to Google Sheets
data "google_service_account" "service_account" {
  account_id = local.vars.SHEETS_ACCESS_SERVICE_ACCOUNT
  depends_on = [
    resource.google_project_service.enable_apis
  ]
}
