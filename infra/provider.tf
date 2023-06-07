terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
  }
  backend "gcs" {
    bucket = "another-blog-proj-tfstate"
    prefix = "terraform/blog"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
