terraform {
  backend "s3" {
    bucket = "mybucket-2000-0903"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-2"
}

data "aws_ami" "ubuntu2204ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "myinstance" {
  ami           = data.aws_ami.ubuntu2204ami.id
  instance_type = "t3.micro"

  tags = {
    Name = "myinstance"
  }
}