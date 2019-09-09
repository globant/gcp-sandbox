variable "credentials_path" {
  description = "Path to credentials for service account used by Terraform."
}

variable "gsuite_admin_email" {
  description = "G-Suite administrator email address to manage your Forseti installation."
}

variable "org_domain" {
  description = "GCP Organization domain that Forseti will have purview over"
}

variable "forseti_project_id" {
  description = "Google Project ID that you want Forseti deployed into."
}

variable "bakery_project_id" {
  description = ""
}

variable "region" {
  description = "GCP region where Forseti will be deployed"
}

variable "organization_id" {
  description = "GCP Organization ID that Forseti will have purview over."
}

variable "cloudsql_network" {
  description = "The VPC where the Forseti client and server will be created."
}

variable "whitelist_projects" {
  description = ""
}

variable "cscc_violations_enabled" {
  description = "Notify for CSCC violations."
}

variable "server_tags" {
  description = "GCE Forseti Server VM Tags	"
}