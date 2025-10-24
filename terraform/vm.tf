resource "google_compute_instance" "test_vm" {
  project      = var.project_id
  zone         = "${var.gcp_region}-b"
  name         = "${var.app_name}-test-vm"
  machine_type = "e2-medium"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
  metadata_startup_script = file("${path.module}/test/vm-startup.sh")

  service_account {
    scopes = ["cloud-platform"]
  }
}

output "test_vm_ip" {
  description = "The external IP address of the test VM."
  value       = google_compute_instance.test_vm.network_interface[0].access_config[0].nat_ip
}

output "test_vm_name" {
    description = "The name of the test VM."
    value = google_compute_instance.test_vm.name
}
