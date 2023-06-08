terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
  }
  backend "gcs" {
    bucket = yamldecode(file("${var.schema_file_path}/project.yaml"))["tfstate_bucket"]
    prefix = "terraform/blog"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
