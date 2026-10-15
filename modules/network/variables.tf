variable "project_id" {
  description = "GCP project ID for this environment"
  type        = string
}

variable "region" {
  description = "Regional location for the subnet and Cloud Run services"
  type        = string
}

variable "environment" {
  description = "Environment name: test, dev, or prod"
  type        = string
}

variable "subnet_cidr" {
  description = "Non-overlapping IPv4 range assigned to this environment subnet"
  type        = string
}
