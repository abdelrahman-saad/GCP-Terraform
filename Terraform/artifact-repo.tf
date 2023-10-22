resource "google_artifact_registry_repository" "my-repo" {
  location      = var.used_region_1
  repository_id = "gcp-terraform-as-repo"
  description   = "example docker repository"
  format        = "DOCKER"
}