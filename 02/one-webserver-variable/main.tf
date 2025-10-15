provider "aws" {
  region = var.my_region
}

resource "aws_instance" "example" {
  ami                         = var.my_ubuntu_ami2204
  instance_type               = var.my_instance_type
  user_data_replace_on_change = var.my_userdata_changed
  tags                        = var.my_web_server_tag
  vpc_security_group_ids      = [aws_security_group.allow_80.id]

  user_data = <<EOF
        #!/bin/bash 
        sudo apt update
        sudo apt -y install apache2
        echo "WEB" | sudo tee /var/www/html/index.html
        sudo systemctl enable --now apache2    
    EOF
}

resource "aws_security_group" "allow_80" {
  name        = "allow_80"
  description = "Allow 80 inbound traffic and all outbound traffic"
  tags        = var.my_sg_tags
}

# SG ingress rule
resource "aws_vpc_security_group_ingress_rule" "allow_http_80" {
  security_group_id = aws_security_group.allow_80.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.my_http_port
  to_port           = var.my_http_port
  ip_protocol       = "tcp"
}

# SG egress rule
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_80.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}