provider "aws" {
    region = "us-east-2"
}

resource "aws_instance" "example" {
    ami = "ami-0cfde0ea8edd312d4"
    instance_type = "t3.micro"

    user_data = <<EOF
        #!/bin/bash 
        sudo apt -y install apache2
        echo "WEB" | sudo tee /var/www/html/index.html
        sudo systemctl enable --now apache2    
    EOF

    vpc_security_group_ids = [aws_security_group.allow_8080.id]
    
    user_data_replace_on_change = true

    tags = {
        Name = "ec2-ubuntu-web-server"
    }
}

resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow 8080 inbound traffic and all outbound traffic"
  tags = {
    Name = "my_allow_8080"
  }
}

# SG ingress rule
resource "aws_vpc_security_group_ingress_rule" "allow_http_8080" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# SG egress rule
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}