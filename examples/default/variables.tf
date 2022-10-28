##############################################################################
# Account Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
  default     = "icse"
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
}

variable "tags" {
  description = "List of tags to apply to resources created by this module."
  type        = list(string)
  default     = []
}

variable "service_endpoints" {
  description = "Service endpoints. Can be `public`, `private`, or `public-and-private`"
  type        = string
  default     = "private"

  validation {
    error_message = "Service endpoints can only be `public`, `private`, or `public-and-private`."
    condition     = contains(["public", "private", "public-and-private"], var.service_endpoints)
  }
}

variable "use_resource_group_ids" {
  description = "OPTIONAL - Use resource group IDs instead of passing in existing resource group names."
  type        = bool
  default     = false
}

##############################################################################

##############################################################################
# Key Management Variables
##############################################################################

variable "disable_key_management" {
  description = "OPTIONAL - If true, key management resources will not be created."
  type        = bool
  default     = false
}

variable "key_management" {
  description = "Configuration for Key Management Service"
  type = object({
    name                      = string
    use_hs_crypto             = optional(bool) # Will force data source to be used. If not true, will default to kms
    use_data                  = optional(bool)
    authorize_vpc_reader_role = optional(bool)
    resource_group_name       = optional(string) # Resource group for key management resources
  })
  default = {
    name                      = "kms"
    authorize_vpc_reader_role = true
  }
}

variable "keys" {
  description = "List of keys to be created for the service"
  type = list(
    object({
      name            = string
      root_key        = optional(bool)
      payload         = optional(string)
      key_ring        = optional(string) # Any key_ring added will be created
      force_delete    = optional(bool)
      endpoint        = optional(string) # can be public or private
      iv_value        = optional(string) # (Optional, Forces new resource, String) Used with import tokens. The initialization vector (IV) that is generated when you encrypt a nonce. The IV value is required to decrypt the encrypted nonce value that you provide when you make a key import request to the service. To generate an IV, encrypt the nonce by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.
      encrypted_nonce = optional(string) # The encrypted nonce value that verifies your request to import a key to Key Protect. This value must be encrypted by using the key that you want to import to the service. To retrieve a nonce, use the ibmcloud kp import-token get command. Then, encrypt the value by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.
      policies = optional(
        object({
          rotation = optional(
            object({
              interval_month = number
            })
          )
          dual_auth_delete = optional(
            object({
              enabled = bool
            })
          )
        })
      )
    })
  )

  default = []

  validation {
    error_message = "Each key must have a unique name."
    condition     = length(var.keys) == 0 ? true : length(distinct(var.keys[*].name)) == length(var.keys[*].name)
  }

  validation {
    error_message = "Key endpoints can only be `public` or `private`."
    condition = length(var.keys) == 0 ? true : length([
      for kms_key in var.keys :
      true if kms_key.endpoint != null && kms_key.endpoint != "public" && kms_key.endpoint != "private"
    ]) == 0
  }

  validation {
    error_message = "Rotation interval month can only be from 1 to 12."
    condition = length(var.keys) == 0 ? true : length([
      for kms_key in [
        for rotation_key in [
          for policy_key in var.keys :
          policy_key if policy_key.policies != null
        ] :
        rotation_key if rotation_key.policies.rotation != null
      ] : true if kms_key.policies.rotation.interval_month < 1 || kms_key.policies.rotation.interval_month > 12
    ]) == 0
  }
}

##############################################################################

##############################################################################
# Object Storage Variables
##############################################################################

variable "cos_use_random_suffix" {
  description = "Add a randomize suffix to the end of each Object Storage resource created in this module."
  type        = bool
  default     = true
}

variable "cos" {
  description = "Object describing the cloud object storage instance, buckets, and keys. Set `use_data` to true to use existing instance instance"
  type = list(
    object({
      name                = string
      use_data            = optional(bool)
      resource_group_name = optional(string)
      plan                = optional(string)
      buckets = list(object({
        name                  = string
        storage_class         = string
        endpoint_type         = string
        force_delete          = bool
        single_site_location  = optional(string)
        region_location       = optional(string)
        cross_region_location = optional(string)
        kms_key               = optional(string)
        allowed_ip            = optional(list(string))
        hard_quota            = optional(number)
        archive_rule = optional(object({
          days    = number
          enable  = bool
          rule_id = optional(string)
          type    = string
        }))
        activity_tracking = optional(object({
          activity_tracker_crn = string
          read_data_events     = bool
          write_data_events    = bool
        }))
        metrics_monitoring = optional(object({
          metrics_monitoring_crn  = string
          request_metrics_enabled = optional(bool)
          usage_metrics_enabled   = optional(bool)
        }))
      }))
      keys = optional(
        list(object({
          name        = string
          role        = string
          enable_HMAC = bool
        }))
      )

    })
  )

  default = []

  validation {
    error_message = "Each COS key must have a unique name."
    condition = length(var.cos) == 0 ? true : length(
      flatten(
        [
          for instance in var.cos :
          [
            for keys in instance.keys :
            keys.name
          ] if lookup(instance, "keys", false) != false
        ]
      )
      ) == length(
      distinct(
        flatten(
          [
            for instance in var.cos :
            [
              for keys in instance.keys :
              keys.name
            ] if lookup(instance, "keys", false) != false
          ]
        )
      )
    )
  }

  validation {
    error_message = "Plans for COS instances can only be `lite` or `standard`."
    condition = length(var.cos) == 0 ? true : length([
      for instance in var.cos :
      true if contains(["lite", "standard"], instance.plan)
    ]) == length(var.cos)
  }

  validation {
    error_message = "COS Bucket names must be unique."
    condition = length(var.cos) == 0 ? true : length(
      flatten([
        for instance in var.cos :
        instance.buckets[*].name
      ])
      ) == length(
      distinct(
        flatten([
          for instance in var.cos :
          instance.buckets[*].name
        ])
      )
    )
  }

  # https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-classes
  validation {
    error_message = "Storage class can only be `standard`, `vault`, `cold`, or `smart`."
    condition = length(var.cos) == 0 ? true : length(
      flatten(
        [
          for instance in var.cos :
          [
            for bucket in instance.buckets :
            true if contains(["standard", "vault", "cold", "smart"], bucket.storage_class)
          ]
        ]
      )
    ) == length(flatten([for instance in var.cos : [for bucket in instance.buckets : true]]))
  }

  # https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cos_bucket#endpoint_type
  validation {
    error_message = "Endpoint type can only be `public`, `private`, or `direct`."
    condition = length(var.cos) == 0 ? true : length(
      flatten(
        [
          for instance in var.cos :
          [
            for bucket in instance.buckets :
            true if contains(["public", "private", "direct"], bucket.endpoint_type)
          ]
        ]
      )
    ) == length(flatten([for instance in var.cos : [for bucket in instance.buckets : true]]))
  }

  # https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cos_bucket#single_site_location
  validation {
    error_message = "All single site buckets must specify `ams03`, `che01`, `hkg02`, `mel01`, `mex01`, `mil01`, `mon01`, `osl01`, `par01`, `sjc04`, `sao01`, `seo01`, `sng01`, or `tor01`."
    condition = length(var.cos) == 0 ? true : length(
      [
        for site_bucket in flatten(
          [
            for instance in var.cos :
            [
              for bucket in instance.buckets :
              bucket if lookup(bucket, "single_site_location", null) != null
            ]
          ]
        ) : site_bucket if !contains(["ams03", "che01", "hkg02", "mel01", "mex01", "mil01", "mon01", "osl01", "par01", "sjc04", "sao01", "seo01", "sng01", "tor01"], site_bucket.single_site_location)
      ]
    ) == 0
  }

  # https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cos_bucket#region_location
  validation {
    error_message = "All regional buckets must specify `au-syd`, `eu-de`, `eu-gb`, `jp-tok`, `us-east`, `us-south`, `ca-tor`, `jp-osa`, `br-sao`."
    condition = length(var.cos) == 0 ? true : length(
      [
        for site_bucket in flatten(
          [
            for instance in var.cos :
            [
              for bucket in instance.buckets :
              bucket if lookup(bucket, "region_location", null) != null
            ]
          ]
        ) : site_bucket if !contains(["au-syd", "eu-de", "eu-gb", "jp-tok", "us-east", "us-south", "ca-tor", "jp-osa", "br-sao"], site_bucket.region_location)
      ]
    ) == 0
  }

  # https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cos_bucket#cross_region_location
  validation {
    error_message = "All cross-regional buckets must specify `us`, `eu`, `ap`."
    condition = length(var.cos) == 0 ? true : length(
      [
        for site_bucket in flatten(
          [
            for instance in var.cos :
            [
              for bucket in instance.buckets :
              bucket if lookup(bucket, "cross_region_location", null) != null
            ]
          ]
        ) : site_bucket if !contains(["us", "eu", "ap"], site_bucket.cross_region_location)
      ]
    ) == 0
  }

  # https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cos_bucket#archive_rule
  validation {
    error_message = "Each archive rule must specify a type of `Glacier` or `Accelerated`."
    condition = length(var.cos) == 0 ? true : length(
      [
        for site_bucket in flatten(
          [
            for instance in var.cos :
            [
              for bucket in instance.buckets :
              bucket if lookup(bucket, "archive_rule", null) != null
            ]
          ]
        ) : site_bucket if !contains(["Glacier", "Accelerated"], site_bucket.archive_rule.type)
      ]
    ) == 0
  }
}

##############################################################################

##############################################################################
# Secrets Manager Variables
##############################################################################

variable "secrets_manager" {
  description = "Map describing an optional secrets manager deployment"
  type = object({
    use_secrets_manager = bool
    name                = optional(string)
    kms_key_name        = optional(string)
    resource_group_name = optional(string)
  })
  default = {
    use_secrets_manager = false
  }
}

##############################################################################

##############################################################################
# forced variables
##############################################################################

variable "resource_group" {
  description = "Mandatory value unused by this module"
  type        = string
  default     = null
}

variable "resource_tags" {
  description = "Mandatory value unused by this module"
  type        = list(string)
  default     = null
}

##############################################################################
