terraform {
  required_version = ">= 0.10.0"

  backend "gcs" {
    credentials = "../../credentials.json"
    bucket      = "tf-remote-state-test"
    prefix      = "istio-sample-env/state/infra"
  }
}

locals {
  project_id             = "${var.project_id}"
  region                 = "${var.region}"
  istio_cluster_admin    = "${var.istio_cluster_admin}"
  istio_cluster_name     = "${var.istio_cluster_name}"
  network_name           = "${var.network_name}"
  subnet_name            = "${var.subnet_name}"
  subnet_range           = "${var.subnet_range}"
  node_pool_name         = "${var.node_pool_name}"
  node_pool_machine_type = "${var.node_pool_machine_type}"
  preemptible_nodes      = "${var.preemptible_nodes}"
}

// Begin provider definitions

provider "google-beta" {
  credentials = "../../credentials.json"
  project     = "${local.project_id}"
  region      = "${local.region}"
}

provider "google" {
  credentials = "../../credentials.json"
  project     = "${local.project_id}"
  region      = "${local.region}"
}

provider "kubernetes" {
  insecure = true
}

// Generate VPC network for project

resource "google_compute_network" "vpc_network" {
  name                    = "${local.network_name}"
  project                 = "${local.project_id}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "${local.subnet_name}"
  region        = "${local.region}"
  project       = "${local.project_id}"
  ip_cidr_range = "${local.subnet_range}"
  network       = "${google_compute_network.vpc_network.self_link}"
}


// Deploy GKE Cluster with Istio
resource "google_container_cluster" "istio_cluster" {
  provider   = "google-beta"
  name       = "${local.istio_cluster_name}"
  location   = "${local.region}"
  network    = "${google_compute_network.vpc_network.self_link}"
  subnetwork = "${google_compute_subnetwork.vpc_subnet.self_link}"

  depends_on = [
    "google_compute_subnetwork.vpc_subnet",
  ]

  remove_default_node_pool = true
  initial_node_count       = 2

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  network_policy {
    enabled = true
  }

  addons_config {
    istio_config {
      disabled = false
      auth     = "AUTH_MUTUAL_TLS"
    }
  }
}

resource "google_container_node_pool" "istio_cluster_preemptible_nodes" {
  name       = "${local.node_pool_name}"
  location   = "${local.region}"
  project    = "${local.project_id}"
  cluster    = "${google_container_cluster.istio_cluster.name}"
  node_count = 2

  node_config {
    preemptible  = "${local.preemptible_nodes}"
    machine_type = "${local.node_pool_machine_type}"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

// Retrieve information from created cluster

data "google_container_cluster" "istio_cluster" {
  project  = "${local.project_id}"
  name     = "${google_container_cluster.istio_cluster.name}"
  location = "${google_container_cluster.istio_cluster.location}"
}

// Add cluster admin role binding
resource "kubernetes_cluster_role_binding" "cluster_admin" {
  metadata {
    name = "istio_cluster_admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = "${local.istio_cluster_admin}"
    api_group = "rbac.authorization.k8s.io"
  }
}
