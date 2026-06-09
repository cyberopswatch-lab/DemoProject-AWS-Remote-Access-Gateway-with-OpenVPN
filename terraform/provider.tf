terraform {
    
  backend "s3" {

    bucket         = "secure-enclave-tfstate-123456"

    key            = "vpn/terraform.tfstate"

    region         = "us-east-1"

    dynamodb_table = "terraform-locks"

    encrypt        = true

  }

  required_providers {

    aws = {

      source  = "hashicorp/aws"

      version = "~>5.50"

    }

  }

}

provider "aws" {

  region = var.aws_region

}