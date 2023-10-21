provider "google" {
  credentials = file("../secrets/gcp-terraform-as.json")
  project     = var.project_id
}