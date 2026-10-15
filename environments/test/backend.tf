terraform {
  backend "gcs" {
    bucket = "devops-504813-iac-20261015-test-tfstate"
    prefix = "terraform/state"
  }
}
