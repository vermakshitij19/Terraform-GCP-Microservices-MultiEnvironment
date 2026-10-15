locals {
  required_apis = toset([
    "compute.googleapis.com",
    "run.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ])

  microservices = {
    catalog = {
      name = "catalog-api"
      cpu  = "1"
      mem  = "512Mi"
      max  = 3
    }
    orders = {
      name = "orders-api"
      cpu  = "1"
      mem  = "512Mi"
      max  = 3
    }
    payments = {
      name = "payments-api"
      cpu  = "1"
      mem  = "512Mi"
      max  = 2
    }
    notifications = {
      name = "notifications-api"
      cpu  = "1"
      mem  = "512Mi"
      max  = 2
    }
  }
}

resource "google_project_service" "required" {
  for_each = local.required_apis
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

module "network" {
  source      = "../../modules/network"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  subnet_cidr = var.subnet_cidr
  depends_on  = [google_project_service.required]
}

module "microservices" {
  for_each = local.microservices
  source   = "../../modules/cloud-run-service"

  project_id         = var.project_id
  region             = var.region
  environment        = var.environment
  service_name       = "${var.environment}-${each.value.name}"
  image              = var.service_image
  network_id         = module.network.network_id
  subnet_id          = module.network.subnet_id
  cpu                = each.value.cpu
  memory             = each.value.mem
  max_instance_count = each.value.max
  depends_on         = [google_project_service.required]
}
