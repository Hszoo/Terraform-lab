output "alb_dns_url" {
    value = "http://${aws_lb.myalb.dns_name}"
}
