locals {
  payload = sensitive("secret-payload-example")
}

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = null
  existing_resource_group_name = "demo-sa-resource-group"
}

##############################################################################
# Secrets Manager
##############################################################################

module "secrets_manager" {
  source               = "terraform-ibm-modules/secrets-manager/ibm"
  version              = "1.1.4"
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  secrets_manager_name = "demo-sa-secrets-manager"
  sm_service_plan      = "trial"
  service_endpoints    = "public-and-private"
}

module "secrets_manager_arbitrary_secret" {
  source                  = "terraform-ibm-modules/secrets-manager-secret/ibm"
  version                 = "1.3.0"
  region                  = var.region
  secrets_manager_guid    = module.secrets_manager.secrets_manager_guid
  secret_name             = "demo-sa-example-secret"
  secret_description      = "created for a demo of schematics agent"
  secret_type             = "arbitrary" #checkov:skip=CKV_SECRET_6
  secret_payload_password = local.payload
}

data "ibm_iam_account_settings" "iam_account_settings" {
}

module "cbr_zone_vpc" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.20.1"
  depends_on       = [module.secrets_manager_arbitrary_secret]
  name             = "demo-sa-VPC-network-zone"
  zone_description = "For schematics agent demo - CBR Network zone containing agent VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = var.schematics_agent_vpc_crn,
  }]
}

module "cbr_rules" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.20.1"
  depends_on       = [module.secrets_manager_arbitrary_secret]
  rule_description = "For schematic agent demo, limit operations on the secrets manager to only originating from agent VPC"
  enforcement_mode = "report"
  rule_contexts = [
    {
      attributes = [
        {
          name  = "networkZoneId"
          value = module.cbr_zone_vpc.zone_id
        }
      ]
    }
  ]
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = module.secrets_manager.secrets_manager_guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "secrets-manager"
        operator = "stringEquals"
      }
  ] }]
  operations = [
    {
      api_types = [
        {
          api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
        },
        {
          api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::platform-api-type:"
        }
      ]
    }
  ]

}
