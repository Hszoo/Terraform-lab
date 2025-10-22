##############################################
# ALB - TargetGroup(:ASG) Attachment - EC2 
##############################################
# 1) VPC, Subnet
# 2) TG, SG, Launch Template, ASG
# 3) ALB, ALB Listener, ALB Listener Rules
##############################################

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
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
## TG (Target Group)
resource "aws_lb_target_group" "myalb-tg" {
  name     = "tf-example-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3 
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
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

resource "aws_vpc_security_group_ingress_rule" "allow_8080_ingress_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_8080_egress_ipv4" {
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
resource "aws_launch_template" "myTemplate" {
  name = "myTemplate"
  image_id = "ami-0cfde0ea8edd312d4" # ubuntu
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_8080.id]

  user_data = base64encode(templatefile("userdata.sh", {
    db_address = data.terraform_remote_state.myRemoteState.outputs.db_address
    db_port = data.terraform_remote_state.myRemoteState.outputs.db_port
    server_port = 8080
  }))

  lifecycle {
    create_before_destroy = true
  }
}

## ASG (Auto Scaling Group)
resource "aws_autoscaling_group" "myASG" {
  vpc_zone_identifier = data.aws_subnets.default.ids

  depends_on = [aws_lb_target_group.myalb-tg]
  target_group_arns = [aws_lb_target_group.myalb-tg.arn]
  
  desired_capacity   = 2
  max_size           = 10
  min_size           = 2

  launch_template {
    id      = aws_launch_template.myTemplate.id
    version = "$Latest"
  }
}

# 3) ALB, ALB Listener, ALB Listener Rules

## ALB Security Group 
resource "aws_security_group" "myalbSG" {
  name = "myalb-SG" 
  description = "Allow 80 inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "allow_80"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_80_ingress_ipv4" {
  security_group_id = aws_security_group.myalbSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_80_egress_ipv4" {
  security_group_id = aws_security_group.myalbSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

## ALB (Application Load Balancer) 
resource "aws_lb" "myalb" {
  name               = "myalb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myalbSG.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false # for test

  tags = {
    Environment = "production"
  }
}

## ALB Listener
resource "aws_lb_listener" "myalb-listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = "80"
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

