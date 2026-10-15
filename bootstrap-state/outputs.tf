output "state_buckets" {
  description = "Created GCS buckets; copy these exact names into each environment backend.tf."
  value = {
    for environment, bucket in google_storage_bucket.terraform_state : environment => bucket.name
  }
}
