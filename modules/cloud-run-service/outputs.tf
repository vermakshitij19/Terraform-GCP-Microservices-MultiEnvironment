output "name" {
  value = google_cloud_run_v2_service.this.name
}

output "url" {
  description = "Service URL; invocation still requires Cloud Run IAM authorization"
  value       = google_cloud_run_v2_service.this.uri
}

output "runtime_service_account" {
  value = google_service_account.runtime.email
}
