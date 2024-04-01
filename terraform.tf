terraform {
  backend "s3" {
    bucket         = "isidrov-terraform"
    key            = "isidrov-terraform/multiregionpoc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_states"
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.43.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  required_version = "~> 1.7.0"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
}

provider "aws" {
  region = "us-west-1"
  alias  = "us_west_1"
}

module "multiregionpoc_us_west_1" {
  source = "./lambda_consumer"
  providers = {
    aws = aws.us_west_1
  }
  name_prefix = "us_west_1"
}

module "multiregionpoc_us_east_1" {
  source = "./lambda_consumer"
  providers = {
    aws = aws.us_east_1
  }
  name_prefix = "us_east_1"
}
