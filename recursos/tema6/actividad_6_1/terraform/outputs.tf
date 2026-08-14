output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.principal.id
}

output "subred_publica_id" {
  description = "ID de la subred pública"
  value       = aws_subnet.publica.id
}

output "subred_privada_id" {
  description = "ID de la subred privada"
  value       = aws_subnet.privada.id
}
