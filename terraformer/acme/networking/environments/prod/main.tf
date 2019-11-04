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
    prefix = "Network/state/prod"
  }
}

module "main_vpc" {
  source   = "../../../modules/gcs_vpc"
  vpc_name = "${var.vpc_name}"
}

module "main_subnet" {
  source          = "../../modules/gcs_subnet"
  subnetwork_name = "${var.subnetwork_name}"
  subnetwork_cidr = "${var.subnetwork_cidr}"
  subnetwork_vpc  = "${module.main_vpc.self_link}"
}
