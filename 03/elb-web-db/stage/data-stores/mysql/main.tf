terraform {
  backend "s3" {
    bucket = "my-bucket-2000-0903-0909"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "myDynamodbTable"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-2"
}

resource "aws_db_instance" "mydb_instance" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.dbuser
  password             = var.dbpassword
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}