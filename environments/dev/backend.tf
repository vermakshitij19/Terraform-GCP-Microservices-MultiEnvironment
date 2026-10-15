terraform {
  backend "gcs" {
    bucket = "devops-504813-iac-20261015-dev-tfstate"
    prefix = "terraform/state"
  }
}
