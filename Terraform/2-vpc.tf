resource "google_compute_network" "application-vpc" {
  name                      = var.vpc_name
  auto_create_subnetworks   = false
  
}