variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "service_name" {
  description = "Unique Cloud Run service name within the project and region"
  type        = string
}

variable "image" {
  description = "Container image reference"
  type        = string
}

variable "network_id" {
  description = "VPC self-link used for Direct VPC egress"
  type        = string
}

variable "subnet_id" {
  description = "Subnet self-link used for Direct VPC egress"
  type        = string
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "512Mi"
}

variable "max_instance_count" {
  type    = number
  default = 3

  validation {
    condition     = var.max_instance_count >= 1 && var.max_instance_count <= 20
    error_message = "max_instance_count must be between 1 and 20 for this demo."
  }
}
