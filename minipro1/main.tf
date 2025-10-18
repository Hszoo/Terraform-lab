###########################################################
# Mini Project 1 - Developer Environment Configuration
###########################################################
# 1. VPC 
#     * VPC 생성 
#     * Internet Gateway 생성 및 VPC에 연결
# 2. Public Subnet
# 3. Routing Table
#     * Public Subnet에 대한 Routing Table 생성
#     * Public Subnet에 Routing Table 연결
# 4. EC2
#     * Security Group 생성
#     * EC2 생성 
###########################################################

## 1. VPC 생성 
##  주의
##     - enable_dns_support=true
##     - enable_dns_hostname=true
##   * VPC cidr_block = 10.123.0.0/16 
resource "aws_vpc" "MyVPC" {
  cidr_block = "10.123.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true  

  tags = {
    Name = "MyVPC"
  }
}

## Internet Gateway 생성 및 VPC에 연결 
resource "aws_internet_gateway" "MyIGW" {
  vpc_id = aws_vpc.MyVPC.id

  tags = {
    Name = "myIGW"
  }
}

## 2. Public Subnet
#     * Public Subnet 생성 
#     * map_public_ip_on_launch = true 
#     * public_subnet_cidr_block = 10.123.1.0/24 

resource "aws_subnet" "MyPubSN" {
  vpc_id     = aws_vpc.MyVPC.id
  cidr_block = "10.123.1.0/24"

  tags = {
    Name = "MyPubSN"
  }
}

## 3. Routing Table 
#     * Public Subnet에 대한 Route Table 생성 
#     * Public Subnet에 대한 Routing Table 연결 

## Routing Table 생성
resource "aws_route_table" "MyPubRT" {
  vpc_id = aws_vpc.MyVPC.id

  route { // ipv4
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIGW.id
  } 

  tags = {
    Name = "MyPubRT"
  }
}

# Routing Table - SN associate 
resource "aws_route_table_association" "MyPubRTassoc" {
  subnet_id      = aws_subnet.MyPubSN.id
  route_table_id = aws_route_table.MyPubRT.id
}


# Security Group 
resource "aws_security_group" "allow_all_traffic" {
  name        = "allow_all_traffic"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.MyVPC.id

  tags = {
    Name = "allow_all_traffic"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_all_traffic" {
  security_group_id = aws_security_group.allow_all_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

## EC2 생성 - ami 지정 
data "aws_ami" "ubuntu2404" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# EC2 Key pair 생성
resource "aws_key_pair" "MyDeveloperKey" {
  key_name   = "my-deployer-key"
  public_key = file("~/.ssh/devkey.pub")
}

# EC2 생성
resource "aws_instance" "MyEC2" {
  ami           = data.aws_ami.ubuntu2404.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.allow_all_traffic.id]
  subnet_id = aws_subnet.MyPubSN.id
  key_name = aws_key_pair.MyDeveloperKey.key_name

  tags = {
    Name = "myEC2"
  }
}