terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.68.0"
    }
  }
}

provider "google" {
  project = local.project_config.project_id
  region  = local.project_config.region
}
