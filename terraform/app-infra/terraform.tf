terraform {
  required_version = "~> 1.15.7"

  backend "s3" {
    bucket       = "spotify-project-remote-storage"
    key          = "spotify/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}
