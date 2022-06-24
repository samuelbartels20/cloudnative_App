resource "aws_instance" "cloudnativeApp_mongo" {
  ami                    = "ami-02868af3c3df4b3aa"
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]

  user_data = filebase64("${path.module}/install.sh")

  tags = {
    Name  = "cloudnativeApp_mongo"
  }
}