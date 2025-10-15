## Input Variable 정의 
variable "my_region" {
  description = "AWS My Region"
  type        = string
  default     = "us-east-2"
}

variable "my_ubuntu_ami2204" {
  description = "AWS MY AMI - Ubuntu 24.04 LTS(x86_64)"
  type        = string
  default     = "ami-0cfde0ea8edd312d4"
}

variable "my_instance_type" {
  description = "My Ubuntu instance type"
  type        = string
  default     = "t3.micro"
}

variable "my_userdata_changed" {
  description = "My User Data Replace on Change"
  type        = bool
  default     = true
}

variable "my_web_server_tag" {
  description = "My Web Server Tag"
  type        = map(any)
  default = {
    Name = "ec2-ubuntu-web-server"
  }
}

variable "my_sg_tags" {
  description = "My Security Group Tags"
  type        = map(string)
  default = {
    Name = "my_allow_80"
  }
}

variable "my_http_port" {
  description = "My Web Server Port"
  type        = number
  default     = 80
}