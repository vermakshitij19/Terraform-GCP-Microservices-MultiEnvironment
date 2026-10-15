variable "project_id" {
  description = "Existing GCP project ID for this environment"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["test", "dev", "prod"], var.environment)
    error_message = "environment must be test, dev, or prod."
  }
}

variable "region" {
  description = "GCP region for the VPC subnet and Cloud Run services"
  type        = string
  default     = "asia-south1"
}

variable "subnet_cidr" {
  description = "One unique /24 subnet per environment"
  type        = string
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid IPv4 CIDR range."
  }
}

variable "service_image" {
  description = "Placeholder container image; replace with a real image for each app in a later iteration"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}
