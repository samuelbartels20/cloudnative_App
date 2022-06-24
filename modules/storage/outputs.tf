output "private_ip" {
  description = "private ip address"
  value       = aws_instance.cloudnativeApp_mongo.private_ip
}