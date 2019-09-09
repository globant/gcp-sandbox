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
    prefix = "Security/state/prod/forsetiservers"
  }
}

module "forseti_instance_group" {
  source = "../../../modules/forsetihaservers"

  project_id              = "${var.forseti_project_id}"
  server_region           = "${var.region}"
  subnetwork              = "${data.terraform_remote_state.vpcbase.forseti_subnet}"
  instance_startup_script = "${data.terraform_remote_state.forsetibase.forseti-mig-startup-script}"
  repository_project_id   = "${var.repository_project_id}"
  image_family_id         = "${var.image_family_id}"
  forseti_service_account = "${data.terraform_remote_state.forsetibase.forseti-server-service-account}"
  instance_startup_script = "${data.terraform_remote_state.forsetibase.forseti-mig-startup-script-content}"
  server_tags             = "${var.server_tags}"
}
