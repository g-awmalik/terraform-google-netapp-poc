resource "google_compute_instance" "cvo_instance_n" {
  name         = "cvs-instance-n"
  machine_type = "e2-medium"
  zone         = "us-central1-c"
  project      = var.project_id
  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }

  network_interface {
    network = "default"
  }
}
