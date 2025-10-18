# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Variable declarations
variable "aws_region" {
    description = "AWS region" 
    type = string
    default = "us-east-2"
}

variable "vpc_cidr_block" {
    description = "VPC CIDR block"
    type = string
    default = "10.0.0.0/16"
}

variable "instance_count" {
    description = "EC2 Instance count"
    type = number 
    default = 2
}

variable "enable_vpn_gateway" {
    description = "Enable a VPN Gateway in your VPC"
    type = bool
    default = false
}

variable "disable_vpn_gateway" {
    description = "Disable VPN Gateway in your VPC"
    type = bool
    default = false
}

variable "private_subnet_count" {
    description = "Number Of Private Subnet Count"
    type = number
    default = 2
}

variable "public_subnet_count" {
    description = "Number Of Public Subnet Count"
    type = number
    default = 2
}

variable "private_subnet_cidr_blocks" {
    description = "Private Subnet CIDR blocks"
    type = list(string)
    default = [
        "10.0.1.0/24", 
        "10.0.2.0/24",
        "10.0.3.0/24",
        "10.0.4.0/24",
        "10.0.5.0/24",
        "10.0.6.0/24",
        "10.0.7.0/24",
        "10.0.8.0/24"
    ]
}

variable "public_subnet_cidr_blocks" {
    description = "Public Subnet CIDR blocks"
    type = list(string)
    default = [
        "10.0.101.0/24",
        "10.0.102.0/24",
        "10.0.103.0/24",
        "10.0.104.0/24",
        "10.0.105.0/24",
        "10.0.106.0/24",
        "10.0.107.0/24",
        "10.0.108.0/24",
    ]
}

variable "resource_tags" {
    description = "Tags to set for all resources"
    type = map(string)
    default = {
        project = "project-alpha"
        environment = "dev"
    }
}

variable "ec2_instance_type" {
    description = "AWS EC2 instance type"
    type = string
}