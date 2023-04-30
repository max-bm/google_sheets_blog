locals {
    project_iam_roles = [
    "roles/bigquery.admin"
  ]
}

data "google_project" "project" {
    project_id = var.project_id
}


resource "google_project_iam_member" "set_roles" {
  for_each = toset(local.project_iam_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}