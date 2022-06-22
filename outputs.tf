output "vpc_id" {
  value = aws_vpc.cloudnativeApp_vpc.id
}

output "subnet1_id" {
  value = aws_subnet.cloudnativeApp_subnet1.id
}

output "subnet2_id" {
  value = aws_subnet.cloudnativeApp_subnet2.id
}

output "subnet3_id" {
  value = aws_subnet.cloudnativeApp_subnet3.id
}

output "alb_dns_name" {
  description = "alb dns"
  value       = aws_lb.cloudnativeApp-alb.dns_name
}

