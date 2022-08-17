##############################################################################
# Resource Group where VPC Resources Will Be Created
##############################################################################

data "ibm_resource_group" "resource_group" {
  for_each = var.use_resource_group_ids == true ? toset([]) : toset(
    distinct(
      concat(
        [
          for instance in var.cos :
          instance.resource_group_name if instance.resource_group_name != null
        ],
        flatten([
          [
            for group in(var.key_management.resource_group_name == null ? [] : [var.key_management.resource_group_name]) :
            group
          ],
          [
            for group in(var.secrets_manager.resource_group_name == null ? [] : [var.secrets_manager.resource_group_name]) :
            group
          ]
        ])
      )
    )
  )
  name = each.key
}

##############################################################################


##############################################################################
# Key Management
##############################################################################

module "key_management" {
  for_each                  = var.disable_key_management == true ? {} : { "key_management" : true }
  source                    = "git://github.com/terraform-ibm-modules/terraform-ibm-icse-key-management.git"
  region                    = var.region
  prefix                    = var.prefix
  tags                      = var.tags
  service_endpoints         = var.service_endpoints
  resource_group_id         = var.use_resource_group_ids == true ? var.key_management.resource_group_name : var.key_management.resource_group_name == null ? null : data.ibm_resource_group.resource_group[var.key_management.resource_group_name].id
  use_hs_crypto             = var.key_management.use_hs_crypto
  use_data                  = var.key_management.use_data
  authorize_vpc_reader_role = var.key_management.authorize_vpc_reader_role
  name                      = var.key_management.name
  keys                      = var.keys
}

locals {
  key_management_service_name = var.key_management.use_hs_crypto == true ? "hs-crypto" : "kms"
}

##############################################################################

##############################################################################
# Object Storage
##############################################################################

module "cloud_object_storage" {
  source                      = "git://github.com/terraform-ibm-modules/terraform-ibm-icse-cos.git"
  region                      = var.region
  prefix                      = var.prefix
  tags                        = var.tags
  use_random_suffix           = var.cos_use_random_suffix
  service_endpoints           = var.service_endpoints
  key_management_service_guid = var.disable_key_management == false ? null : module.key_management["key_management"].key_management_guid
  key_management_service_name = var.disable_key_management == false ? null : local.key_management_service_name
  key_management_keys         = var.disable_key_management == false ? [] : module.key_management["key_management"].keys
  cos = [
    for instance in var.cos :
    merge(instance, {
      resource_group_id = (
        var.use_resource_group_ids == true
        ? instance.resource_group_name
        : instance.resource_group_name == null
        ? null
        : data.ibm_resource_group.resource_group[instance.resource_group_name].id
      )
    })
  ]
}

##############################################################################
