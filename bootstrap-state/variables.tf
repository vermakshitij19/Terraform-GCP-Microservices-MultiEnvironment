variable "state_project_id" {
  description = "Existing GCP project that temporarily hosts Terraform state buckets"
  type        = string
  default     = "devops-504813"
}

variable "region" {
  description = "GCS bucket location"
  type        = string
  default     = "asia-south1"
}

variable "bucket_prefix" {
  description = "Globally unique lowercase prefix for the state bucket names"
  type        = string
  default     = "devops-504813-iac-20261015"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{4,48}[a-z0-9]$", var.bucket_prefix))
    error_message = "bucket_prefix must be 6-50 characters, lowercase letters/numbers/hyphens, starting and ending with a letter or number."
  }
}
