variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Token"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Resource group name"
  default     = "us-south"
}

variable "secret_manager_guid" {
  type        = string
  description = "GUID of secret manager instance"
}

variable "secret_id" {
  type        = string
  description = "The ID of the secret to get"
}
