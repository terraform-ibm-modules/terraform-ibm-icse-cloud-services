##############################################################################
# Fail if COS Buckets use key not found in key_management key definition
##############################################################################

locals {
  cos_bucket_key_names = distinct(
    flatten([
      for instance in var.cos :
      [
        for bucket in instance.buckets :
        bucket.kms_key if bucket.kms_key != null
      ] if length(instance.buckets) > 0
    ])
  )
  kms_key_names = var.keys[*].name
  cos_buckets_have_valid_keys = length([
    for bucket in local.cos_bucket_key_names :
    false if !contains(local.kms_key_names, bucket)
  ]) == 0
  configuration_failure_unfound_cos_bucket_key = regex("true",
    length(local.cos_bucket_key_names) == 0 && length(var.keys) == 0
    ? true
    : var.disable_key_management == true && length(local.cos_bucket_key_names) > 0
    ? false
    : var.disable_key_management == true && length(local.cos_bucket_key_names) == 0
    ? true
    : length(var.keys) == 0 && length(local.cos_bucket_key_names) > 0
    ? false
    : local.cos_buckets_have_valid_keys
  )
}

##############################################################################
