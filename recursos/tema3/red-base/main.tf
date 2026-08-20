terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "pistas" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "pistas-vpc-${var.identificador}"
  }
}

resource "aws_internet_gateway" "pistas" {
  vpc_id = aws_vpc.pistas.id

  tags = {
    Name = "pistas-igw-${var.identificador}"
  }
}

resource "aws_subnet" "publica_a" {
  vpc_id            = aws_vpc.pistas.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "pistas-publica-a"
  }
}

resource "aws_subnet" "privada_a" {
  vpc_id            = aws_vpc.pistas.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "pistas-privada-a"
  }
}

resource "aws_subnet" "publica_b" {
  vpc_id            = aws_vpc.pistas.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "pistas-publica-b"
  }
}

resource "aws_subnet" "privada_b" {
  vpc_id            = aws_vpc.pistas.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "pistas-privada-b"
  }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.pistas.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pistas.id
  }

  tags = {
    Name = "pistas-rt-publica-${var.identificador}"
  }
}

resource "aws_route_table_association" "publica_a" {
  subnet_id      = aws_subnet.publica_a.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table_association" "publica_b" {
  subnet_id      = aws_subnet.publica_b.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_security_group" "pistas_base" {
  name        = "pistas-sg-base-${var.identificador}"
  description = "SSH abierto (Instance Connect) y trafico interno libre entre instancias del mismo grupo"
  vpc_id      = aws_vpc.pistas.id

  ingress {
    description = "SSH - la misma regla abierta que ya usas para EC2 Instance Connect desde el aula (Actividad 2.2)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pistas-sg-base-${var.identificador}"
  }
}

resource "aws_security_group_rule" "interno_todo" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.pistas_base.id
  source_security_group_id = aws_security_group.pistas_base.id
  description               = "Trafico interno entre instancias del mismo grupo (incluye NFS/2049 para EFS)"
}
