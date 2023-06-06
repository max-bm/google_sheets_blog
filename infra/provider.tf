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
