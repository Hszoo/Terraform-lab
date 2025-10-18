######################
# ALB + TG(ASG)
######################
# 1. Launch Template
#    * SG 
#    * LT 
# 2. ASG
# 3. TG
#    * SG 
#    * TG 
# 4. ALB
#    * ALB Listener 
#    * ALB rules 
#    * 
######################



## 1. Launch Template 
#     * SG 
#     * LT 

## default vpc
data "aws_vpc" "default" { // 프로바이더의 default vpc 사용
  default = true
}

## Security Group for Web servers
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "allow_web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_80" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  to_port           = var.server_http_port
  from_port         = var.server_http_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_443" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  to_port           = var.server_https_port
  from_port         = var.server_https_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

## Amazon Linux 2023 AMI
data "aws_ami" "amz2023ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

## Launch Template for Web servers 
resource "aws_launch_template" "myLT" {
  name = "myLT"

  image_id = data.aws_ami.amz2023ami.id

  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.allow_web.id]

  # https://developer.hashicorp.com/terraform/language/functions/filebase64
  user_data = filebase64("./LT_user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}


## 2. ASG 

## Subnet for ASG 
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

## ASG for Web Servers 
resource "aws_autoscaling_group" "myASG" {
  vpc_zone_identifier = data.aws_subnets.default_subnets.ids
  desired_capacity    = 2
  min_size            = var.instance_min_size
  max_size            = var.instance_max_size

  # [중요]
  target_group_arns = [aws_lb_target_group.myTG.arn]
  depends_on = [aws_lb_target_group.myTG]

  launch_template {
    id = aws_launch_template.myLT.id
  }
}

## 3. TG 
## Security Group for TargetGroup 

## Target Group for ALB Web Servers
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "myTG" {
  name        = "myALB-TG"
  target_type = "instance"
  port        = var.server_http_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

## 4. ALB 
# ALB 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "MyALB" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web.id]
  subnets            = data.aws_subnets.default_subnets.ids

  # enable_deletion_protection = true
} 

# ALB Listener 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "myALB_listener" {
  load_balancer_arn = aws_lb.MyALB.arn
  port              = var.server_http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "myALB_rule" {
  listener_arn = aws_lb_listener.myALB_listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myTG.arn
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.MyALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page Not Found"
      status_code  = "404"
    }
  }
}

# ALB Listener Rule 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.myALB_listener.arn 
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myTG.arn
  }
}
