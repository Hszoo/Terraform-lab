output "alb_dns_name" {
  value = aws_lb.MyALB.dns_name
}

output "alb_url" {
  value = "http://${aws_lb.MyALB.dns_name}:${var.server_http_port}"
}