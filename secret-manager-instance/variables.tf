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

variable "schematics_agent_vpc_crn" {
  type        = string
  description = "The VPC crn that contains the schematic agent for demo"
}
