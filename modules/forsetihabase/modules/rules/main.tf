#
#  Copyright 2019 Google LLC. 
# 
#  This software is provided as is, without warranty 
#  or representation for any use or purpose. Your use 
#  of it is subject to your agreement with Google. 
#

locals {
  whitelist_projects = "${var.whitelist_projects}"
}

data "template_file" "log_sink_rules" {
  template = "${file("${path.module}/templates/log_sink_rules.tpl")}"

  vars {
    org_id = "${var.org_id}"
  }
}

data "template_file" "bucket_rules" {
  template = "${file("${path.module}/templates/bucket_rules.tpl")}"

  vars {
    org_id = "${var.org_id}"
  }
}

data "template_file" "service_account_key_rules" {
  template = "${file("${path.module}/templates/service_account_key_rules.tpl")}"
}

data "template_file" "instance_network_interface_rules" {
  template = "${file("${path.module}/templates/instance_network_interface_rules.tpl")}"

  vars {
    whitelist = "${join("\n", "${formatlist("       %s:\n        - default", local.whitelist_projects)}")}"
  }
}

resource "google_storage_bucket_object" "log_sink_rules" {
  name    = "rules/log_sink_rules.yaml"
  bucket  = "${var.bucket}"
  content = "${data.template_file.log_sink_rules.rendered}"
}

resource "google_storage_bucket_object" "bucket_rules" {
  name    = "rules/bucket_rules.yaml"
  bucket  = "${var.bucket}"
  content = "${data.template_file.bucket_rules.rendered}"
}

resource "google_storage_bucket_object" "service_account_key_rules" {
  name    = "rules/service_account_key_rules.yaml"
  bucket  = "${var.bucket}"
  content = "${data.template_file.service_account_key_rules.rendered}"
}

resource "google_storage_bucket_object" "instance_network_interface_rules" {
  name    = "rules/instance_network_interface_rules.yaml"
  bucket  = "${var.bucket}"
  content = "${data.template_file.instance_network_interface_rules.rendered}"
}
