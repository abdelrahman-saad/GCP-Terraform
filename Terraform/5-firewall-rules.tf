resource "google_compute_firewall" "deny-all" {
  name    = "deny-all"
  network = google_compute_network.application-vpc.id
  priority = 1001
  deny {
    protocol = "tcp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "inbound-ip-ssh" {
    name        = "allow-incoming-ssh-from-iap"
    project     = var.project_id
    network     = google_compute_network.application-vpc.id

    direction = "INGRESS"
    allow {
        protocol = "tcp"
        ports    = ["22"]  
    }
    source_ranges = [
        "35.235.240.0/20"
    ]
    target_tags = [ "iap-instances" ]
    
}