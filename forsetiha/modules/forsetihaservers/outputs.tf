#
#  Copyright 2019 Google LLC. 
# 
#  This software is provided as is, without warranty 
#  or representation for any use or purpose. Your use 
#  of it is subject to your agreement with Google. 
#

output "forseti-template-selflink" {
  description = "Self link for Forseti Instance Template"
  value       = "${google_compute_instance_template.forseti.self_link}"
}

output "load-balancer-ip-address" {
  description = "IP address for the server load balancer"
  value       = "${google_compute_address.balancer_address.address}"
}
