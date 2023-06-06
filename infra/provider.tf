terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.63.1"
    }
  }
  backend "gcs" {
    bucket = "blog-is-annoying-tfstate"
    prefix = "terraform/blog"
  }
}
