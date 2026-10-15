terraform {
  backend "gcs" {
    bucket = "devops-504813-iac-20261015-prod-tfstate"
    prefix = "terraform/state"
  }
}
