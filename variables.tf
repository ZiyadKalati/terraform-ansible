variable "region" {
  default = "ca-central-1"
  type = string
}

variable "availability_zone" {
  default = "ca-central-1a"
  type = string
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
  type    = string
}

variable "subnet_cidr_block" {
  default = "10.0.0.0/24"
  type    = string
}

variable "ec2_name_prefix" {
  default = "aa-terraform"
  type    = string
}

variable "private_key_file" {
  default = "secret.pem"
  type    = string
}

