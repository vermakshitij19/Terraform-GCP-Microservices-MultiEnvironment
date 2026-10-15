resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = "${var.service_name}-sa"
  display_name = "Runtime identity for ${var.service_name} (${var.environment})"
  description  = "Least-privilege runtime identity for ${var.service_name}. Add only required permissions."
}

resource "google_cloud_run_v2_service" "this" {
  project  = var.project_id
  name     = var.service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  # Protect production services from accidental deletion.
  deletion_protection = var.environment == "prod"

  template {
    service_account                  = google_service_account.runtime.email
    timeout                          = "60s"
    max_instance_request_concurrency = 80

    scaling {
      min_instance_count = 0
      max_instance_count = var.max_instance_count
    }

    containers {
      image = var.image

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      env {
        name  = "APP_ENVIRONMENT"
        value = var.environment
      }

      env {
        name  = "SERVICE_NAME"
        value = var.service_name
      }
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"

      network_interfaces {
        network    = var.network_id
        subnetwork = var.subnet_id
      }
    }
  }
}
