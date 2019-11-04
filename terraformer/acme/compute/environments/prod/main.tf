#"Copyright 2019 Globant LLC
#
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License."

#prod terraform module instantiation

provider "google" {
  project = "watersedge"
  region  = "us-west1"
}

terraform {
  backend "gcs" {
    bucket = "state-bucket-961aa1ca4d3101c4"
    prefix = "Compute/state/prod"
  }
}

module "default_vm" {

  source             = "../../../modules/gcs_compute"
  vm_name            = "${var.vm_name}"
  vm_type            = "${var.vm_type}"
  vm_zone            = "${var.vm_zone}"
  vm_os              = "${var.vm_os}"
  vm_network_name    = "${data.terraform_remote_state.networking.outputs.vpc_name}"
  vm_subnetwork_name = "${data.terraform_remote_state.networking.outputs.subnetwork_name}"
  vm_sa_email        = "${data.terraform_remote_state.iam.outputs.service_account_email}"
}
