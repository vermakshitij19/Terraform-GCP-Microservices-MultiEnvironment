variable "project_id" {
  description = "Existing dedicated GCP project ID for Prod"
  type        = string
}

variable "environment" {
  type = string
  validation {
    condition     = var.environment == "prod"
    error_message = "The Prod root must use environment = prod."
  }
}

variable "region" {
  type    = string
  default = "asia-south1"
}

variable "subnet_cidr" {
  type = string
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid IPv4 CIDR range."
  }
}

variable "service_image" {
  type    = string
  default = "us-docker.pkg.dev/cloudrun/container/hello"
}
