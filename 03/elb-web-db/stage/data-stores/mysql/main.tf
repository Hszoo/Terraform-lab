terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "my-bucket-2000-0903-0909"
    # bucket-bsc-7979/global/s3/terraform.tfstate
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "myDynamodbTable"
    encrypt        = true
  }
}

## RDS: Mysql 
resource "aws_db_instance" "mydb_instance" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.dbuser ## 변수화 
  password             = var.dbpassword ## 변수화 
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}