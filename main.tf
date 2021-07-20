terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

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

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "main" {
  ami                       = data.aws_ami.ubuntu.id
  instance_type             = "t3.micro"
  availability_zone         = var.availability_zone
  subnet_id                 = aws_subnet.main.id
  vpc_security_group_ids    = [aws_security_group.allow_http.id]
  key_name                  = "${var.ec2_name_prefix}-secret"

  tags = {
    Name = "${var.ec2_name_prefix}-1"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      host        = aws_instance.main.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_file)
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.main.public_ip},' -u ubuntu --private-key ${var.private_key_file} ansible/docker.yml ansible/nginx.yml"
  }
  
}
