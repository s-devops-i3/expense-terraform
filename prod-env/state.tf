terraform {
  backend "s3" {
    bucket = "shuja-bucket2"
    key    = "project-terraform/prod/state"
    region = "us-east-1"
  }
}