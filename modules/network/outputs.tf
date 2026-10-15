output "network_id" {
  description = "VPC self-link used by Cloud Run Direct VPC egress"
  value       = google_compute_network.this.id
}

output "network_name" {
  value = google_compute_network.this.name
}

output "subnet_id" {
  description = "Subnet self-link used by Cloud Run Direct VPC egress"
  value       = google_compute_subnetwork.this.id
}

output "subnet_name" {
  value = google_compute_subnetwork.this.name
}

output "subnet_cidr" {
  value = google_compute_subnetwork.this.ip_cidr_range
}
