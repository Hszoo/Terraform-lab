provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "mybucket-2000-0903"

  tags = {
    Name        = "mybucket"
  }
}

resource "aws_dynamodb_table" "terraform-locks" {
  name             = "terraform-locks"
  hash_key         = "LockID"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}