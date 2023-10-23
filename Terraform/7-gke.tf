
resource "google_container_cluster" "workload_cluster" {
  name     = "workload-cluster"
  location = var.used_region_2
  network = google_compute_network.application-vpc.id
  subnetwork = google_compute_subnetwork.workload_subnet.id

  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = var.gke_cider
  }
  master_authorized_networks_config {
      cidr_blocks {
          cidr_block = var.first_cider
          display_name = "vm"
      }
    }

  deletion_protection = false

  node_pool {
    name       = "my-node-pool"
    node_count = 1
    node_locations = [ 
      "${var.used_region_2}-a",
      "${var.used_region_2}-b",
      "${var.used_region_2}-c"
     ]
    
    node_config {
      preemptible  = true
      machine_type = "e2-small"
      disk_type    = "pd-standard"
      disk_size_gb = 15
      service_account = google_service_account.gke-reader-sa.email
      oauth_scopes    = [ 
      "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }
}

resource "google_service_account" "gke-reader-sa" {
  account_id   = "gke-reader-sa"
  display_name = "GKE SA to read Images"
}

resource "google_project_iam_member" "artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke-reader-sa.email}"
}