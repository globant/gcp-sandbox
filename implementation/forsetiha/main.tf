locals {
  credentials_file_path = "${var.credentials_path}"
}

provider "google-beta" {
  credentials = "${file("${local.credentials_file_path}")}"
}

terraform {
  required_version = ">= 0.10.0"

  backend "gcs" {
    bucket = "tf-remote-state"
    prefix = "Terraform/state/forsetibase"
  }
}

module "forseti_ha_deploy" {
  source = "../../forsetiha"

  gsuite_admin_email      = "${var.gsuite_admin_email}"
  domain                  = "${var.org_domain}"
  project_id              = "${var.forseti_project_id}"
  bakery_project_id       = "${var.bakery_project_id}"
  server_region           = "${var.region}"
  org_id                  = "${var.organization_id}"
  cloudsql_network        = "${var.cloudsql_network}"
  whitelist_projects      = "${var.whitelist_projects}"
  cscc_violations_enabled = "${var.cscc_violations_enabled}"
}
