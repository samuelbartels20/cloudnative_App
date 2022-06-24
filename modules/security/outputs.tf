output "application_sg_id" {
  description = "web server sg id"
  value       = aws_security_group.cloudnativeApp_aws_security_group_application.id
}

output "alb_sg_id" {
  description = "alb sg id"
  value       = aws_security_group.cloudnativeApp_aws_security_group_alb.id
}

output "mongodb_sg_id" {
  description = "mongodb sg id"
  value       = aws_security_group.mongodb.id
}

output "bastion_sg_id" {
  description = "bastion sg id"
  value       = aws_security_group.cloudnativeAp_aws_security_group_bastion.id
}
