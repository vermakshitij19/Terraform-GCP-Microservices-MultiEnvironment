resource "google_compute_network" "this" {
  name                    = "${var.environment}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  description             = "Custom VPC for the ${var.environment} environment"
}

resource "google_compute_subnetwork" "this" {
  name                     = "${var.environment}-subnet"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
}
