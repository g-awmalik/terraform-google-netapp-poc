locals {
  new_instance_id = google_compute_instance.cvo_instance_n.self_link
}

module "cvo_ig" {
  source     = "../"
  project_id = var.project_id
  cvo_instances = concat(
    [local.new_instance_id],
    tolist(data.google_compute_instance_group.cvo_ig.instances)
  )
}

data "google_compute_image" "debian_image" {
  family  = "debian-11"
  project = "debian-cloud"
}

data "google_compute_instance_group" "cvo_ig" {
  name    = "staging-instance-group"
  zone    = "us-central1-c"
  project = var.project_id
}
