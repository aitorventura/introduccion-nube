variable "identificador" {
  description = "Tu identificador personal, el mismo que has usado en el resto del módulo (por ejemplo, tus iniciales)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.identificador))
    error_message = "El identificador debe tener entre 2 y 20 caracteres: minúsculas, números y guiones."
  }
}

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
  description = "Tipo de instancia para la instancia de prueba que se añade en la Parte B (todavía no se usa en ningún recurso)"
  type        = string
  default     = "t3.micro"
}
