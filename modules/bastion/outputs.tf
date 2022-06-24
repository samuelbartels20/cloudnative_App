output "public_ip" {
  description = "public ip address"
  value       = aws_instance.cloudnativeApp_aws_instance_bastion.public_ip
}