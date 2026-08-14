# Módulo de ejemplo: VPC mínima con una subred pública y una privada
# Actividad 6.1 — Destruir y reconstruir
#
# Este módulo es autocontenido: no depende de ninguna infraestructura
# creada a mano en otras sesiones. Declara una VPC genérica de ejemplo,
# lista para leer, modificar, aplicar y destruir.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "disponibles" {
  state = "available"
}

resource "aws_vpc" "principal" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "vpc-actividad61-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone       = data.aws_availability_zones.disponibles.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "subred-publica-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "privada" {
  vpc_id            = aws_vpc.principal.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = data.aws_availability_zones.disponibles.names[1]

  tags = {
    Name        = "subred-privada-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "principal" {
  vpc_id = aws_vpc.principal.id

  tags = {
    Name        = "igw-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.principal.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.principal.id
  }

  tags = {
    Name        = "rt-publica-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.publica.id
}
