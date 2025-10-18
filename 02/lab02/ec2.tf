########################
## EC2 생성 
########################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.16.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

## 최신 Amazon Linux 2023 AMI 검색
data "aws_ami" "amazonLinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

## EC2 인스턴스
resource "aws_instance" "myInstance" {
  ami                         = data.aws_ami.amazonLinux.id
  instance_type               = "t3.micro"
  key_name                    = "mykeypair"
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "myInstance"
  }
}

## 보안 그룹
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  tags = {
    Name = "allow_ssh"
  }
}

## SSH 허용 (ingress)
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.allow_ssh.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

## 모든 아웃바운드 허용 (egress)
resource "aws_security_group_rule" "allow_all_traffic" {
  type              = "egress"
  security_group_id = aws_security_group.allow_ssh.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

output "ami_id" {
  value       = data.aws_ami.amazonLinux.id
  description = "Amazon Linux 2023 AMI ID"
}
