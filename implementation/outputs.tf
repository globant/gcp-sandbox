output "forseti-server-service-account" {
  description = "Forseti Server service account"
  value       = "${module.forseti_ha_deploy.forseti-server-service-account}"
}

output "forseti-server-storage-bucket" {
  description = "Forseti Server storage bucket"
  value       = "${module.forseti_ha_deploy.forseti-server-storage-bucket}"
}
