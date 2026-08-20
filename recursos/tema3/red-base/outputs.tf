output "vpc_id" {
  value = aws_vpc.pistas.id
}

output "subnet_publica_a_id" {
  value = aws_subnet.publica_a.id
}

output "subnet_privada_a_id" {
  value = aws_subnet.privada_a.id
}

output "subnet_publica_b_id" {
  value = aws_subnet.publica_b.id
}

output "subnet_privada_b_id" {
  value = aws_subnet.privada_b.id
}

output "security_group_id" {
  value = aws_security_group.pistas_base.id
}
