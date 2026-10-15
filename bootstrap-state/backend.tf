# After running the bootstrap apply locally, copy this file to backend.tf.
# Update bucket to the exact bootstrap bucket name shown by terraform output.
terraform {
  backend "gcs" {
    bucket = "devops-504813-iac-20261015-bootstrap-tfstate"
    prefix = "terraform/state"
  }
}
