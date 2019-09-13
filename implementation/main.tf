provider "google-beta" {
  credentials = "${local.credentials_file_path}"
  project     = "${local.forseti_project_id}"
}

provider "google" {
  credentials = "${local.credentials_file_path}"
  project     = "${local.forseti_project_id}"
}

terraform {
  required_version = ">= 0.10.0"

  backend "gcs" {
    bucket      = "tf-remote-state-test"
    prefix      = "Terraform/state/forsetiha"
    credentials = "../credentials.json"
  }
}

# Definition of local values needed by the respurce modules
locals {
  credentials_file_path   = "../credentials.json"
  org_domain              = "gcpsandbox.cloud"
  forseti_project_id      = "lab-forsetiha"
  region                  = "us-west1"
  organization_id         = "63734882150"
  cscc_violations_enabled = "true"
}

# Creates a VPC network and a subnet in the project Forseti will be deployed
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network-01"
  project                 = "${local.forseti_project_id}"
  auto_create_subnetworks = "False"
}

resource "google_compute_subnetwork" "forseti_vpc_subnet" {
  name          = "subnetwork-01"
  project       = "${local.forseti_project_id}"
  ip_cidr_range = "10.2.0.0/16"
  region        = "${local.region}"
  network       = "${google_compute_network.vpc_network.self_link}"
}

module "forseti_ha_deploy" {
  source = "../forsetiha"

  domain                  = "${local.org_domain}"
  project_id              = "${local.forseti_project_id}"
  server_region           = "${local.region}"
  org_id                  = "${local.organization_id}"
  network                 = "${google_compute_network.vpc_network.self_link}"
  subnetwork              = "${google_compute_subnetwork.forseti_vpc_subnet.self_link}"
  cscc_violations_enabled = "${local.cscc_violations_enabled}"
}
