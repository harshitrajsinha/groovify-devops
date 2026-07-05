terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.51.0"
    }
  }

  backend "s3" {
    bucket       = var.remote_backend_bucket_name
    key          = var.remote_backend_bucket_key
    region       = var.region
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}