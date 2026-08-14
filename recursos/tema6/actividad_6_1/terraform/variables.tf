variable "environment" {
  description = "Entorno de despliegue (dev o prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El valor de environment debe ser \"dev\" o \"prod\"."
  }
}

variable "vpc_cidr" {
  description = "Rango CIDR de la VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "instance_type" {
  description = "Tipo de instancia para la instancia de prueba que se añade en la Parte B"
  type        = string
  default     = "t2.micro"
}
