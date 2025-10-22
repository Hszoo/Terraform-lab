output "tags" {
  description = "Instance tags"
  value       = aws_instance.ubuntu[*].tags
}

output "private_addresses" {
  description = "Private DNS for AWS instances"
  value       = aws_instance.ubuntu[*].private_dns
}

output "first_tags" {
  description = "Instance tags for first instance"
  value       = aws_instance.ubuntu[0].tags
}