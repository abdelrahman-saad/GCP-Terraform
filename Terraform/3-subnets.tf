resource "google_compute_subnetwork" "management_subnet" {
  name          = "management"
  ip_cidr_range = var.first_cider
  region        = var.used_region_1
  network       = google_compute_network.application-vpc.id
}


resource "google_compute_subnetwork" "workload_subnet" {
  name          = "workload"
  ip_cidr_range = var.second_cider
  region        = var.used_region_2
  network       = google_compute_network.application-vpc.id

}