resource "google_compute_instance_group" "staging_group" {
  name      = "staging-instance-group"
  zone      = "us-central1-c"
  instances = var.cvo_instances
  project   = var.project_id
  named_port {
    name = "http"
    port = "8080"
  }

  named_port {
    name = "https"
    port = "8443"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_backend_service" "staging_service" {
  name      = "staging-service"
  port_name = "https"
  protocol  = "HTTPS"
  project   = var.project_id

  backend {
    group = google_compute_instance_group.staging_group.id
  }

  health_checks = [
    google_compute_https_health_check.staging_health.id,
  ]
}

resource "google_compute_https_health_check" "staging_health" {
  name         = "staging-health"
  request_path = "/health_check"
  project      = var.project_id
}