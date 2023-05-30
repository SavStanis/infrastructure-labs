terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.6"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

# Ubuntu AMI
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

# Security Group
resource "aws_security_group" "lab-web-app-security-group" {
  name        = "lab-web-app-security-group"
  description = "Allow HTTP and SSH access"

  # Inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

# EC2 instance for application
resource "aws_instance" "lab-web-app" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.lab-web-app-security-group.id]

  # Run init shell script
  user_data = file("web-app-init-script.sh")

  tags = {
    Name = "lab-resources"
  }
}
