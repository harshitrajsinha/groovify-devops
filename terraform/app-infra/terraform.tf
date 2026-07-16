terraform {
  required_version = "~> 1.15.7"

  backend "s3" {
    bucket       = "groovify-project-remote-storage"
    key          = "groovify/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}
