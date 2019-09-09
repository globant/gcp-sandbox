/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "forseti-server-service-account" {
  description = "Forseti Server service account"
  value       = "${google_service_account.forseti_server.email}"
}

output "forseti-server-storage-bucket" {
  description = "Forseti Server storage bucket"
  value       = "${google_storage_bucket.server_config.id}"
}

output "forseti-cloudsql-connection-name" {
  description = "The connection string to the CloudSQL instance"
  value       = "${google_sql_database_instance.master.connection_name}"
}

output "forseti-cloudsql-replica-connection-name" {
  description = "The connection string to the read replica CloudSQL instance"
  value       = "${google_sql_database_instance.read_replica.connection_name}"
}

output "forseti_mig_startup_script" {
  description = "The startup script for forseti instance templates"
  value       = "${google_storage_bucket_object.forseti_mig_startup_script.self_link}"
}

output "forseti_mig_startup_script_content" {
  description = "The rendered startup script for forseti instance templates"
  value       = "${data.template_file.forseti_mig_startup_script.rendered}"
}
