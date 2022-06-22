#Initialize terraform backend

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.66.0"
    }
  }
}

# Configure terraform provider
provider "aws" {
  region = var.region
}

# Configure AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = ["099720109477"]
}

# Configure AWS directory service
resource "aws_directory_service_directory" "cloudnativeApp_aws_directory_service_directory" {
  name     = "workspaces.skillembassy.io"
  password = "#S1ncerely"
  size     = "Small"

  vpc_settings {
    vpc_id = aws_vpc.cloudnativeApp_vpc.id
    subnet_ids = [
      aws_subnet.cloudnativeApp_subnet3.id,
      aws_subnet.cloudnativeApp_subnet4.id
    ]
  }
}

# Configure AWS worskapces directory
resource "aws_workspaces_directory" "cloudnativeApp_aws_workspaces_directory" {
  directory_id = aws_directory_service_directory.cloudnativeApp_aws_directory_service_directory.id
  subnet_ids = [
    aws_subnet.cloudnativeApp_subnet3.id,
    aws_subnet.cloudnativeApp_subnet4.id
  ]

  tags = {
    Example = true
  }

  self_service_permissions {
    change_compute_type  = true
    increase_volume_size = true
    rebuild_workspace    = true
    restart_workspace    = true
    switch_running_mode  = true
  }

  workspace_access_properties {
    device_type_android    = "ALLOW"
    device_type_chromeos   = "ALLOW"
    device_type_ios        = "ALLOW"
    device_type_linux      = "ALLOW"
    device_type_osx        = "ALLOW"
    device_type_web        = "ALLOW"
    device_type_windows    = "ALLOW"
    device_type_zeroclient = "ALLOW"
  }

  workspace_creation_properties {
    custom_security_group_id            = aws_security_group.cloudnativeApp_security_group_for_instance.id
    default_ou                          = "OU=AWS,DC=Workgroup,DC=Example,DC=com"
    enable_internet_access              = true
    enable_maintenance_mode             = true
    user_enabled_as_local_administrator = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudnativeApp_workspaces_default_service_access,
    aws_iam_role_policy_attachment.cloudnativeApp_workspaces_default_self_service_access
  ]
}

data "aws_iam_policy_document" "cloudnativeApp_aws_iam_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["workspaces.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudnativeApp_aws_iam_role" {
  name               = "cloudnativeApp_workspaces_DefaultRole"
  assume_role_policy = data.aws_iam_policy_document.cloudnativeApp_aws_iam_policy_document.json
}


resource "aws_iam_role_policy_attachment" "cloudnativeApp_workspaces_default_service_access" {
  role       = aws_iam_role.cloudnativeApp_aws_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesSelfServiceAccess"
}

resource "aws_iam_role_policy_attachment" "cloudnativeApp_workspaces_default_self_service_access" {
  role       = aws_iam_role.cloudnativeApp_aws_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesSelfServiceAccess"
}

# Configure VPC
resource "aws_vpc" "cloudnativeApp_vpc" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"


  tags = {
    Name = "cloudnativeApp_vpc"
    Description = "VPC for cloudnativeApp"
  }
}

# Configure subnet1
resource "aws_subnet" "cloudnativeApp_subnet1" {
  vpc_id            = aws_vpc.cloudnativeApp_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "cloudnativeApp_subnet1"
    Type = "Public"
    Description = "Subnet1 for cloudnativeApp"
  }
}

# configure subnet2
resource "aws_subnet" "cloudnativeApp_subnet2" {
  vpc_id            = aws_vpc.cloudnativeApp_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 2)
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "cloudnativeApp_subnet2"
    Type = "Public"
    Description = "Subnet2 for cloudnativeApp"
  }
}

# Configure subnet3
resource "aws_subnet" "cloudnativeApp_subnet3" {
  vpc_id            = aws_vpc.cloudnativeApp_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 3)
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "cloudnativeApp_subnet3"
    Type = "Private"
    Description = " Subnet3 for cloudnativeApp"
  }
}

# Configure subnet4
resource "aws_subnet" "cloudnativeApp_subnet4" {
  vpc_id            = aws_vpc.cloudnativeApp_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 4)
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "cloudnativeApp_subnet4"
    Type = "Private"
    Description = " Subnet4 for cloudnativeApp"
  }
}

# Configure internet gateway
resource "aws_internet_gateway" "cloudnativeApp_internet_gateway" {
  vpc_id = aws_vpc.cloudnativeApp_vpc.id

  tags = {
    "Name"  = "cloudnativeApp_internet_gateway"
    Description = "Internet gateway for cloudnativeApp"
  }
}

# Configure elastic IP
resource "aws_eip" "cloudnativeApp_elastic_ip" {
  vpc = true
}

resource "aws_nat_gateway" "cloudnativeApp_aws_nat_gateway" {
  allocation_id = aws_eip.cloudnativeApp_elastic_ip.id
  subnet_id     = aws_subnet.cloudnativeApp_subnet1.id

  tags = {
    Name = "cloudnativeApp_aws_nat_gateway"
    Description = " Nat gateway for cloudnativeApp"
  }

  depends_on = [aws_internet_gateway.cloudnativeApp_internet_gateway]
}

# Configure public route table 
resource "aws_route_table" "cloudnativeApp_route_table_public" {
  vpc_id = aws_vpc.cloudnativeApp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudnativeApp_internet_gateway.id
  }

  tags = {
    Name = "Public"
    Description = "Public route  table for cloudnativeApp"
  }
}

# Configure private route table 
resource "aws_route_table" "cloudnativeApp_route_table_private" {
  vpc_id = aws_vpc.cloudnativeApp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudnativeApp_internet_gateway.id
  }

  tags = {
    Name = "Public"
    Description = "Private route  table for cloudnativeApp"
  }
}

#configure the route table association for subnet1
resource "aws_route_table_association" "cloudnativeApp_aws_route_table_association_for_subnet1" {
  subnet_id      = aws_subnet.cloudnativeApp_subnet1.id
  route_table_id = aws_route_table.cloudnativeApp_route_table_public.id

}

#configure the route table association for subnet2
resource "aws_route_table_association" "cloudnativeApp_aws_route_table_association_for_subnet2" {
  subnet_id      = aws_subnet.cloudnativeApp_subnet2.id
  route_table_id = aws_route_table.cloudnativeApp_route_table_public.id

}


#configure the route table association for subnet3
resource "aws_route_table_association" "cloudnativeApp_aws_route_table_association_for_subnet3" {
  subnet_id      = aws_subnet.cloudnativeApp_subnet3.id
  route_table_id = aws_route_table.cloudnativeApp_route_table_private.id

}

#configure the route table association for subnet4
resource "aws_route_table_association" "cloudnativeApp_aws_route_table_association_for_subnet4" {
  subnet_id      = aws_subnet.cloudnativeApp_subnet4.id
  route_table_id = aws_route_table.cloudnativeApp_route_table_private.id

}

# Configure security group
resource "aws_security_group" "cloudnativeApp_security_group_for_instance" {
  name        = "cloudnativeApp_security_group_for_instance"
  description = "Instance security group for cloudnativeApp"
  vpc_id      = aws_vpc.cloudnativeApp_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    description = "80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      cidrsubnet(var.cidr_block, 8, 1),
      cidrsubnet(var.cidr_block, 8, 2)
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow traffic"
    Description = "Allow traffic"
  }
}

# Configure security group for application loadbalancer
resource "aws_security_group" "cloudnativeApp_security_group_for_application-loadbalancer" {
  name        = "cloudnativeApp_security_group_for_application-loadbalancer"
  description = "alb network traffic"
  vpc_id      = aws_vpc.cloudnativeApp_vpc.id

  ingress {
    description = "80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.cloudnativeApp_security_group_for_instance.id]
  }

  tags = {
    Name = "cloudnativeApp_security_group_for_application-loadbalancer"
    Description = "cloudnativeApp_security_group_for_application-loadbalancer"
  }
}

# Configure Instance launch template for cloudnativeApp
resource "aws_launch_template" "cloudnativeApp_instance_launchtemplate1" {
  name = "cloudnativeApp_instance_launchtemplate1"

  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.cloudnativeApp_security_group_for_instance.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "cloudnativeApp_instance_launchtemplate1"
      Description = "Instance for cloudnativeApp"
    }
  }

  user_data = filebase64("${path.module}/ec2.userdata")
}

# configure application loadbalancer
resource "aws_lb" "cloudnativeApp-alb" {
  name               = "cloudnativeApp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cloudnativeApp_security_group_for_application-loadbalancer.id]
  subnets            = [aws_subnet.cloudnativeApp_subnet1.id, aws_subnet.cloudnativeApp_subnet2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "evelopment"
  }
}

# Configure application load balancer target group
resource "aws_alb_target_group" "cloudnativeApp_aws_alb_target_group" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.cloudnativeApp_vpc.id
}

# Configure frontend application loadbalancer listeners
resource "aws_alb_listener" "cloudnativeApp_front_end_aws_alb_listener" {
  load_balancer_arn = aws_lb.cloudnativeApp-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.cloudnativeApp_aws_alb_target_group.arn
  }
}

# Configure application loadbalancer listeners rule1
resource "aws_alb_listener_rule" "cloudnativeApp_aws_alb_listener_rule1" {
  listener_arn = aws_alb_listener.cloudnativeApp_front_end_aws_alb_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.cloudnativeApp_aws_alb_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# Configure auto scaling group
resource "aws_autoscaling_group" "cloudnativeApp_aws_autoscaling_group" {
  vpc_zone_identifier = [aws_subnet.cloudnativeApp_subnet3.id, aws_subnet.cloudnativeApp_subnet4.id]

  desired_capacity = 2
  max_size         = 2
  min_size         = 2

  target_group_arns = [aws_alb_target_group.cloudnativeApp_aws_alb_target_group.arn]

  launch_template {
    id      = aws_launch_template.cloudnativeApp_instance_launchtemplate1.id
    version = "$Latest"
  }
}

