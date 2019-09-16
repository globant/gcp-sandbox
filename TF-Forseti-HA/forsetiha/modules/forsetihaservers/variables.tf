#
#  Copyright 2019 Google LLC. 
# 
#  This software is provided as is, without warranty 
#  or representation for any use or purpose. Your use 
#  of it is subject to your agreement with Google. 
#

variable "project_id" {
  description = "Google Project ID that you want Forseti deployed into"
}

variable "server_tags" {
  description = "GCE Forseti Server VM Tags"
  type        = "list"
  default     = []
}

variable "server_type" {
  description = "GCE Forseti Server role instance size"
  default     = "n1-standard-2"
}

variable "server_region" {
  description = "GCP region where Forseti will be deployed"
  default     = "us-central1"
}

variable "server_instance_metadata" {
  description = "Metadata key/value pairs to make available from within the server instance"
  type        = "map"
  default     = {}
}

variable "instance_startup_script" {
  description = "Rendered startup script for instance templates to deploy in the Managed Instance Group"
}

variable "network" {
  description = "The VPC network where the Forseti client and server will be created"
  default     = "default"
}

variable "subnetwork" {
  description = "The VPC subnetwork where the Forseti client and server will be created"
  default     = "default"
}

variable "forseti_service_account" {
  description = "Service account to run Forseti Server as"
}

variable "server_boot_image" {
  description = "GCE instance image that is being used, currently Debian only support is available"
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
}
