terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
  }
  backend "gcs" {
    bucket = "cts-3d9-objective-bhabha-tfstate"
    prefix = "terraform/blog"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
