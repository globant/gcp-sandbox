#
#  Copyright 2019 Google LLC. 
# 
#  This software is provided as is, without warranty 
#  or representation for any use or purpose. Your use 
#  of it is subject to your agreement with Google. 
#

#----------------------------------#
# Forseti server instance template #
#----------------------------------#

resource "random_id" "random_hash_suffix" {
  byte_length = 4
}

locals {
  random_hash = "${random_id.random_hash_suffix.hex}"
  server_name = "forseti-server-vm-${local.random_hash}"
}

resource "google_compute_instance_template" "forseti" {
  name        = "${local.server_name}"
  description = "This template is used to create forseti server instances."
  project     = "${var.project_id}"

  tags = "${var.server_tags}"

  labels = {
    environment = "prod"
  }

  instance_description = "Forseti default Instance from Template"
  machine_type         = "${var.server_type}"
  can_ip_forward       = false

  //allow_stopping_for_update = true
  metadata                = "${var.server_instance_metadata}"
  metadata_startup_script = "${var.instance_startup_script}"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = "${var.server_boot_image}"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = "${var.subnetwork}"

    //access_config = {
    //  // Remove to delete public IP  
    //}
  }

  service_account {
    email  = "${var.forseti_service_account}"
    scopes = ["cloud-platform"]
  }
}

#--------------------------------#
# Forseti Managed Instance Group #
#--------------------------------#

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  project             = "${var.project_id}"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10                         # 50 seconds

  tcp_health_check {
    port = "50051"
  }
}

resource "google_compute_region_instance_group_manager" "forseti" {
  provider = "google-beta"
  name     = "forseti-igm"

  base_instance_name = "forseti"
  region             = "${var.server_region}"
  project            = "${var.project_id}"
  target_size        = 1

  version {
    name              = "forseti-latest"
    instance_template = "${google_compute_instance_template.forseti.self_link}"
  }

  named_port {
    name = "group1"
    port = 50051
  }

  auto_healing_policies {
    health_check      = "${google_compute_health_check.autohealing.self_link}"
    initial_delay_sec = 300
  }
}

#---------------------------#
# Load Balancer for servers #
#---------------------------#
resource "google_compute_address" "balancer_address" {
  project      = "${var.project_id}"
  name         = "forseti-balancer-address"
  subnetwork   = "${var.subnetwork}"
  address_type = "INTERNAL"
  region       = "${var.server_region}"
}

resource "google_compute_forwarding_rule" "server_balancer" {
  project = "${var.project_id}"
  name    = "forseti-server-balancer"
  region  = "${var.server_region}"

  load_balancing_scheme = "INTERNAL"
  ip_protocol           = "TCP"
  ip_address            = "${google_compute_address.balancer_address.address}"
  backend_service       = "${google_compute_region_backend_service.forseti_backend.self_link}"
  ports                 = ["50051"]
  network               = "${var.network}"
  subnetwork            = "${var.subnetwork}"
}

resource "google_compute_region_backend_service" "forseti_backend" {
  project       = "${var.project_id}"
  name          = "forseti-backend"
  region        = "${var.server_region}"
  health_checks = ["${google_compute_health_check.autohealing.self_link}"]

  backend = {
    group = "${google_compute_region_instance_group_manager.forseti.instance_group}"
  }
}
