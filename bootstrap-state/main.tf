locals {
  environments = toset(["bootstrap", "test", "dev", "prod"])
}

resource "google_project_service" "storage_api" {
  project            = var.state_project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "terraform_state" {
  for_each = local.environments

  name                        = "${var.bucket_prefix}-${each.value}-tfstate"
  project                     = var.state_project_id
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  labels = {
    purpose     = "terraform-state"
    environment = each.value
    managed_by  = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.storage_api]
}
