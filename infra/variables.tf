variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "personal"
}

#external-secrets
variable "external_secrets_enabled" {
  type        = bool
  description = "controls whether or not to deploy external secrets iam access"
  default     = true
}
