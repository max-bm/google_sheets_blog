terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.63.1"
    }
  }
  backend "gcs" {
    bucket = "blog-test-2-389008-tfstate"
    prefix = "terraform/blog"
  }
}

# provider "google" {
#   # Configuration options
#   scopes = ["https://www.googleapis.com/auth/drive",
#     "https://www.googleapis.com/auth/bigquery",
#     "https://www.googleapis.com/auth/cloud-platform",
#   "https://www.googleapis.com/auth/userinfo.email"]
#   project = var.project_id
#   region  = var.region
# }
