variable "aws_region" {

  default = "us-east-1"

}

variable "allowed_ssh_cidr" {

  description = "Your public IP/32"

  type        = string

}

variable "public_key_path" {

  description = "Path to SSH public key"

  type        = string

}

variable "instance_type" {

  default = "t3.micro"

}

variable "openvpn_ami" {

  description = "OpenVPN Access Server Marketplace AMI"

  type        = string

}