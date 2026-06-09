####################################################

# DATA

####################################################

data "aws_availability_zones" "available" {}

####################################################

# VPC

####################################################

resource "aws_vpc" "vpn_vpc" {

  cidr_block           = "10.50.0.0/16"

  enable_dns_hostnames = true

  enable_dns_support   = true

  tags = {

    Name = "secure-enclave-vpc"

  }

}

####################################################

# INTERNET GATEWAY

####################################################

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.vpn_vpc.id

  tags = {

    Name = "secure-enclave-igw"

  }

}

####################################################

# PUBLIC SUBNET

####################################################

resource "aws_subnet" "public" {

  vpc_id                  = aws_vpc.vpn_vpc.id

  cidr_block              = "10.50.1.0/24"

  availability_zone       = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true

  tags = {

    Name = "secure-enclave-public"

  }

}

####################################################

# ROUTING

####################################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.vpn_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id

  }

}

resource "aws_route_table_association" "public" {

  subnet_id      = aws_subnet.public.id

  route_table_id = aws_route_table.public.id

}

####################################################

# KEY PAIR

####################################################

resource "aws_key_pair" "vpn_key" {

  key_name   = "vpn-gateway-key"

  public_key = file(var.public_key_path)

}

####################################################

# SECURITY GROUP

####################################################

resource "aws_security_group" "vpn_gateway_sg" {

  name        = "vpn-gateway-sg"

  description = "OpenVPN Gateway Security Group"

  vpc_id      = aws_vpc.vpn_vpc.id

  ingress {

    description = "HTTPS"

    from_port   = 443

    to_port     = 443

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "OpenVPN Admin UI"

    from_port   = 943

    to_port     = 943

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "OpenVPN Tunnel"

    from_port   = 1194

    to_port     = 1194

    protocol    = "udp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "SSH Restricted"

    from_port   = 22

    to_port     = 22

    protocol    = "tcp"

    cidr_blocks = [var.allowed_ssh_cidr]
    }

  egress {

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {

    Name = "vpn-gateway-sg"

  }

}
####################################################

# OPENVPN ACCESS SERVER

####################################################

resource "aws_instance" "openvpn" {

  ami                    = var.openvpn_ami

  instance_type          = var.instance_type

  subnet_id              = aws_subnet.public.id

  key_name               = aws_key_pair.vpn_key.key_name

  vpc_security_group_ids = [aws_security_group.vpn_gateway_sg.id]

  associate_public_ip_address = true

  root_block_device {

    volume_size = 8

    volume_type = "gp3"

  }

  tags = {

    Name        = "secure-vpn-gateway"

    Environment = "Lab"

    Purpose     = "Secure Enclave Project"

  }

}

resource "aws_instance" "openvpn" {

  ami           = var.openvpn_ami

  instance_type = var.instance_type

  subnet_id              = aws_subnet.public.id

  key_name               = aws_key_pair.vpn_key.key_name

  vpc_security_group_ids = [aws_security_group.vpn_gateway_sg.id]

  associate_public_ip_address = true

  tags = {

    Name = "secure-vpn-gateway"

  }

}