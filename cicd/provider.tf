terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }
  backend "s3" {
    bucket = "devopsme-remote-state"
    key    = "jenkins"  # always change key name for every new resourec
    region = "us-east-1"
    dynamodb_table = "devopsme-locking"
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}