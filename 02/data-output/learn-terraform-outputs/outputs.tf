# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Output declarations

output "vpc_id" {
    description = "VPC ID"
    value = module.vpc.vpc_id
}

output "lb_url" {
    description = "http://(LB DNS NAME)"
    value = "http://${module.elb_http.elb_dns_name}/"
}

output "web_sever_count" {
    description = "Number of web servers provisioned"
    value = length(module.ec2_instances.instance_ids)
}

output "db_username" {
    description = "DB User"
    value = aws_db_instance.database.username
    sensitive = true
}

output "db_password" {
    description = "DB Password"
    value = aws_db_instance.database.password
    sensitive = true
}