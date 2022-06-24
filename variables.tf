variable "key_name" {
  type = string
}

variable "environment" {
  type    = string
  default = "development"
}

variable "cidr_block" {
  type        = string
  description = "VPC cidr block."
}

variable "availability_zones" {
  type = list(any)
}

variable "bastion_instance_type" {
  type = string
}

variable "app_instance_type" {
  type = string
}

variable "db_instance_type" {
  type = string
}