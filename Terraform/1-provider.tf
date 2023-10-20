provider "google" {
  credentials = file("C:/Users/asaad/Desktop/gcp-terraform/GCP-Terraform/secrets/gcp-terraform-as.json")
  project     = var.project_id
}