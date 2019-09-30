output "cluster_username" {
  value = "${data.google_container_cluster.istio_cluster.master_auth.0.username}"
}

output "cluster_password" {
  value = "${data.google_container_cluster.istio_cluster.master_auth.0.password}"
}

output "endpoint" {
  value = "${data.google_container_cluster.istio_cluster.endpoint}"
}

output "instance_group_urls" {
  value = "${data.google_container_cluster.istio_cluster.instance_group_urls}"
}

output "node_config" {
  value = "${data.google_container_cluster.istio_cluster.node_config}"
}

output "node_pools" {
  value = "${data.google_container_cluster.istio_cluster.node_pool}"
}