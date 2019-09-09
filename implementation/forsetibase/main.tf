#
#  Copyright 2019 Google LLC. 
# 
#  This software is provided as is, without warranty 
#  or representation for any use or purpose. Your use 
#  of it is subject to your agreement with Google. 
#

locals {
  credentials_file_path = "${var.credentials_path}"

  env = "prod"
}

provider "google-beta" {
  credentials = "${file("${var.credentials_path}")}"
}

terraform {
  required_version = ">= 0.10.0"

  backend "gcs" {
    bucket = "tf-state-lel"
    prefix = "Security/state/prod/forsetibase"
  }
}

module "forseti_base_template" {
  source = "../../../modules/forsetihabase"

  gsuite_admin_email      = "${var.gsuite_admin_email}"
  domain                  = "${var.org_domain}"
  project_id              = "${var.forseti_project_id}"
  bakery_project_id       = "${var.bakery_project_id}"
  server_region           = "${var.region}"
  org_id                  = "${var.organization_id}"
  cloudsql_network        = "${var.cloudsql_network}"
  whitelist_projects      = "${var.whitelist_projects}"
  cscc_violations_enabled = "${var.cscc_violations_enabled}"
  server_tags             = "${var.server_tags}"
}
