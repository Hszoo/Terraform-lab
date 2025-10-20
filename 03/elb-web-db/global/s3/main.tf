terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.17.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-2"
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "my-bucket-2000-0903-0909"

  tags = {
    Name        = "mybucket"
    Environment = "Dev"
  }
}

resource "aws_dynamodb_table" "myDynamodbTable" {
  name           = "myDynamodbTable"
  hash_key       = "LockID"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}