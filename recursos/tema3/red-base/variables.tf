variable "identificador" {
  description = "Tu identificador personal, el mismo que has usado en el resto del modulo (por ejemplo, tus iniciales)."
  type        = string
}

variable "region" {
  description = "Region de AWS del Learner Lab."
  type        = string
  default     = "us-east-1"
}
