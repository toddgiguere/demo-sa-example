# retrieving information about the arbitrary secret
data "ibm_sm_arbitrary_secret" "arbitrary_secret" {
  instance_id = var.secret_manager_guid
  region      = var.region
  secret_id   = var.secret_id
}

output "arbitrary_secret_nonsensitive_payload" {
  value       = nonsensitive(data.ibm_sm_arbitrary_secret.arbitrary_secret.payload)
  description = "accessing arbitrary secret"
  sensitive   = false
}
