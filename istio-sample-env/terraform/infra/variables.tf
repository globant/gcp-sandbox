// Project configuration
variable "project_id" {
  type        = string
  description = "ID of the project to deploy to."
}

variable "region" {
  type        = string
  description = "GCP region to deploy resources to."
}

// Network configuration
variable "network_name" {
  type        = string
  description = "Name of VPC to create in project."
}

variable "subnet_name" {
  type        = string
  description = "Name of subnetwork to create for resources."
}

variable "subnet_range" {
  type        = string
  description = "CIDR IP range for created subnet."
}

// K8s configuration
variable "istio_cluster_admin" {
  type        = string
  description = "ID of the Kubernetes Cluster Admin."
}

variable "istio_cluster_name" {
  type        = string
  description = "Name of the Kubernetes Cluster."
}

variable "node_pool_name" {
  type        = string
  description = "Name of the Kubernetes node pool."
}

variable "node_pool_machine_type" {
  type        = string
  description = "Machine type for node pool instances."
}

variable "preemptible_nodes" {
  type        = bool
  description = "Makes node pool instances preemtible."
  default     = false
}
