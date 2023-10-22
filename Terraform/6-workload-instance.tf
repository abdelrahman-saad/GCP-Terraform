# create the script template for instance
data "template_file" "startup_script" {
  template = file("../scripts/workload-startup-script.sh")
}


resource "google_compute_instance" "management-instance" {
  name         = "management-vm"
  machine_type = "e2-medium"
  tags         = ["management-instance", "iap-instances"]
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.management_subnet.name
  }

  metadata_startup_script = data.template_file.startup_script.rendered
}