provider "google" {
  credentials = file("/home/abdelrahman/Desktop/GCP Terraform/secrets/gcp-terraform-as.json")
  project     = var.project_id
}