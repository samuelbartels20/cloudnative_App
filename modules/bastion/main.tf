resource "aws_instance" "cloudnativeApp_aws_instance_bastion" {
  ami                         = "ami-0d70546e43a941d70"
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.sg_id]
  associate_public_ip_address = true

  tags = {
    Name  = "cloudnativeApp_aws_instance_bastion"
  }
}