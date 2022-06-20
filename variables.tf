variable "region" {
  type = string
}

variable "instance_type" {
  type = string
}
variable "key_name" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "amis" {
  type = map(any)
  default = {
    "us-east-2" : "ami-02f3416038bdb17fb"
    "eu-central-1" : "ami-065deacbcaac64cf2"
  }
}

variable "cidr_block" {
  type        = string
  description = "VPC cidr block. Example: 10.10.0.0/16"
}

# variable "workstation_ip" {
#   type = string
# }