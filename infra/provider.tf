terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.63.1"
    }
  }
  backend "gcs" {
    bucket = "final-final-blog-test-tfstate"
    prefix = "terraform/blog"
  }
}
