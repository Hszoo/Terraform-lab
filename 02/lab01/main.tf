### 작업 순서  ################################
# VPC 생성                                    #
# IGW 생성 - VPC attach                       # 
# Public Subnet 생성                          # 
# Routing Table 생성 및 Public Subnet에 연결   # 

## provider 설정 
provider "aws" {
  region = "us-east-2"
}

## vpc 생성
resource "aws_vpc" "myVPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "myVPC"
  }
}

## IGW 생성 및 VPC에 연결 
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

## Public Subnet 생성
resource "aws_subnet" "myPublicSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name = "myPublicSN"
  }
}

## Routing Table 생성  
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "myPubRT"
  }
}

## Public Subnet에 연결
resource "aws_route_table_association" "myPubRTasscomyPubSN" {
  subnet_id      = aws_subnet.myPublicSN.id
  route_table_id = aws_route_table.myPubRT.id
}