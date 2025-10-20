##############################################
# ALB - TargetGroup(:ASG) Attachment - EC2 
##############################################
# 1) VPC, Subnet
# 2) TG, SG, Launch Template, ASG
# 3) ALB, ALB Listener, ALB Listener Rules
##############################################

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

# 1) VPC, Subnet

## VPC
data "aws_vpc" "default" {
  default = true
}

## Subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 2) TG, SG, Launch Template, ASG TG

## Target Group
resource "aws_lb_target_group" "myalb_tg" {
  name     = "myalb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

## Security Group
resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow 8080 inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

## Remote state
data "terraform_remote_state" "myRemoteState" {
  backend = "s3"
  config = {
    bucket = "my-bucket-2000-0903-0909"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
  }
}

## Launch Template
resource "aws_launch_template" "myLT" {
  name = "myLT"
  image_id = "ami-0cfde0ea8edd312d4" # ubuntu
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_8080.id]

  user_data = base64encode(templatefile("userdata.sh", {
    db_address = data.terraform_remote_state.myRemoteState.outputs.db_address
    db_port = data.terraform_remote_state.myRemoteState.outputs.db_port
    server_port = 8080
  }))
}

## ASG (Auto Scaling Group)
resource "aws_autoscaling_group" "myASG" {
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns = [aws_lb_target_group.myalb_tg.arn]
  desired_capacity   = 2
  max_size           = 10
  min_size           = 2

  launch_template {
    id      = aws_launch_template.myLT.id
    version = "$Latest"
  }
}

## TG (Target Group)
resource "aws_lb_target_group" "myalb-tg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

# 3) ALB, ALB Listener, ALB Listener Rules

## ALB (Application Load Balancer) 
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_8080.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

## ALB Listener
resource "aws_lb_listener" "myalb-listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myalb-tg.arn
  }
}

## ALB Listener Rule
resource "aws_lb_listener_rule" "myalb-listener-rule" {
  listener_arn = aws_lb_listener.myalb-listener.arn
  priority     = 100


  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myalb-tg.arn
  }
}

