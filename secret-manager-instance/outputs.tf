output "secret_manager_instance_guid" {
  description = "GUID of new secret manager instance"
  value       = module.secrets_manager.secrets_manager_guid
}

output "secret_manager_secret_id" {
  description = "ID of new secret"
  value       = module.secrets_manager_arbitrary_secret.secret_id
}
