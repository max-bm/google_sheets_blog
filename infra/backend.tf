# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "gcs" {
    bucket = "another-blog-proj-tfstate"
    prefix = "terraform/blog"
  }
}
