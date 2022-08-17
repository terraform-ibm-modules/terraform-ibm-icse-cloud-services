##############################################################################
# Secrets Manager Locals
##############################################################################

locals {
  secrets_manager_authorization_count = (
    var.secrets_manager.use_secrets_manager == true # if using secrets
    && var.secrets_manager.kms_key_name != null     # key management key name is not null
    && var.disable_key_management != false          # and key management is not disabled
    ? ["secrets-manager-to-kms"]                    # create authorization policy
    : []                                            # otherwise create no authorizations
  )

  # Authorization policy data
  secrets_manager_authorization = {
    for instance in local.secrets_manager_authorization_count :
    (instance) => {
      name                        = instance
      source_service_name         = "secrets-manager"
      description                 = "Allow secrets manager to read from Key Management"
      roles                       = ["Reader"]
      target_service_name         = local.key_management_service_name
      target_resource_instance_id = module.key_management.key_management_guid
    }
  }
}

##############################################################################

##############################################################################
# Service Authorization Policy
##############################################################################

resource "ibm_iam_authorization_policy" "policy" {
  for_each                    = local.secrets_manager_authorization
  source_service_name         = each.value.source_service_name
  description                 = each.value.description
  roles                       = each.value.roles
  target_service_name         = each.value.target_service_name
  target_resource_instance_id = each.value.target_resource_instance_id
}

##############################################################################

##############################################################################
# Map Keys
##############################################################################

module "encryption_key_map" {
  source         = "./config_modules/list_to_map"
  list           = var.disable_key_management == true ? [] : module.key_management["key_management"].keys
  key_name_field = "shortname"
}

##############################################################################

##############################################################################
# Create Secrets Manager
##############################################################################

resource "ibm_resource_instance" "secrets_manager" {
  count    = var.secrets_manager.use_secrets_manager ? 1 : 0
  name     = "${var.prefix}-${var.secrets_manager.name}"
  service  = "secrets-manager"
  location = var.region
  plan     = "standard"
  resource_group_id = (
    var.use_resource_group_ids == true
    ? var.secrets_manager.resource_group_name
    : var.secrets_manager.resource_group_name == null
    ? null
    : data.ibm_resource_group.resource_group[var.secrets_manager.resource_group_name].id
  )

  parameters = {
    kms_key = (
      lookup(var.secrets_manager, "kms_key_name", null) == null
      ? null
      : module.encryption_key_map.value[var.secrets_manager.kms_key_name].crn
    )
  }

  timeouts {
    create = "1h"
    delete = "1h"
  }

  depends_on = [ibm_iam_authorization_policy.policy]
}

##############################################################################
