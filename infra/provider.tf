terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.63.1"
    }
  }
  backend "gcs" {
    bucket = "blog-testing-sandbox-tfstate"
    prefix = "terraform/blog"
  }
}

# provider "google" {
#   project = var.project_id
#   region  = var.region
# }
