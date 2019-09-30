provider "google-beta" {
  credentials = "${file("../../secrets/credentials.json")}"
  project     = "istio-sample-254516"
  region      = "us-central1"
}

provider "kubernetes" {
  insecure         = true
  load_config_file = false
}

terraform {
  required_version = ">= 0.10.0"

  backend "gcs" {
    bucket = "tf-remote-state-test"
    prefix = "istio-sample-env/state/infra"
  }
}

locals {
  project_id          = "istio-sample-254516"
  istio_cluster_admin = "fgonzalez@gcpsandbox.cloud"
}


// Generate VPC network for project
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network-01"
  project                 = "${local.project_id}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "subnetwork-01"
  region        = "us-central1"
  project       = "${local.project_id}"
  ip_cidr_range = "10.2.0.0/16"
  network       = "${google_compute_network.vpc_network.self_link}"
}


// Deploy GKE Cluster with Istio
resource "google_container_cluster" "istio_cluster" {
  provider   = "google-beta"
  name       = "istio-cluster"
  location   = "us-central1"
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
  name       = "istio-node-pool"
  location   = "us-central1"
  project    = "${local.project_id}"
  cluster    = "${google_container_cluster.istio_cluster.name}"
  node_count = 2

  node_config {
    preemptible  = true
    machine_type = "g1-small"

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