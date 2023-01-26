<!-- BEGIN MODULE HOOK -->

# Terraform IBM Module ICSE Cloud Services Module

<!-- UPDATE BADGE: Update the link for the badge below-->
[![Build Status](https://github.com/terraform-ibm-modules/terraform-ibm-module-template/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-module-template/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

This module creates and manages resources for Cloud Object Storage, Key Management, and Secrets Manager.

## Usage

```terraform
module cloud_services {
  source                 = "github.com/terraform-ibm-modules/terraform-ibm-icse-cloud-services"
  prefix                 = "my-prefix"
  region                 = "us-south"
  tags                   = ["icse"]
  service_endpoints      = "private"
}
```

<!-- PERMISSIONS REQUIRED TO RUN MODULE

If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

<!--
## Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Sample Account Service** service
        - `Editor` platform access
        - `Manager` service access
    - IAM Services
        - **Sample Cloud Service** service
            - `Administrator` platform access
-->

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!--
## Required IAM access policies

No permissions are needed to run this module.
-->

<!-- END MODULE HOOK -->

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [Examples](examples)
<!-- END EXAMPLES HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_object_storage"></a> [cloud\_object\_storage](#module\_cloud\_object\_storage) | git::https://github.com/terraform-ibm-modules/terraform-ibm-icse-cos.git | v1.0.1 |
| <a name="module_encryption_key_map"></a> [encryption\_key\_map](#module\_encryption\_key\_map) | ./config_modules/list_to_map | n/a |
| <a name="module_key_management"></a> [key\_management](#module\_key\_management) | git::https://github.com/terraform-ibm-modules/terraform-ibm-icse-key-management.git | v1.0.3 |

## Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.secrets_manager](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_group.resource_group](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cos"></a> [cos](#input\_cos) | Object describing the cloud object storage instance, buckets, and keys. Set `use_data` to true to use existing instance instance | <pre>list(<br>    object({<br>      name                = string<br>      use_data            = optional(bool)<br>      resource_group_name = optional(string)<br>      plan                = optional(string)<br>      buckets = list(object({<br>        name                  = string<br>        storage_class         = string<br>        endpoint_type         = string<br>        force_delete          = bool<br>        single_site_location  = optional(string)<br>        region_location       = optional(string)<br>        cross_region_location = optional(string)<br>        kms_key               = optional(string)<br>        allowed_ip            = optional(list(string))<br>        hard_quota            = optional(number)<br>        archive_rule = optional(object({<br>          days    = number<br>          enable  = bool<br>          rule_id = optional(string)<br>          type    = string<br>        }))<br>        activity_tracking = optional(object({<br>          activity_tracker_crn = string<br>          read_data_events     = bool<br>          write_data_events    = bool<br>        }))<br>        metrics_monitoring = optional(object({<br>          metrics_monitoring_crn  = string<br>          request_metrics_enabled = optional(bool)<br>          usage_metrics_enabled   = optional(bool)<br>        }))<br>      }))<br>      keys = optional(<br>        list(object({<br>          name        = string<br>          role        = string<br>          enable_HMAC = bool<br>        }))<br>      )<br><br>    })<br>  )</pre> | `[]` | no |
| <a name="input_cos_use_random_suffix"></a> [cos\_use\_random\_suffix](#input\_cos\_use\_random\_suffix) | Add a randomize suffix to the end of each Object Storage resource created in this module. | `bool` | `true` | no |
| <a name="input_disable_key_management"></a> [disable\_key\_management](#input\_disable\_key\_management) | OPTIONAL - If true, key management resources will not be created. | `bool` | `false` | no |
| <a name="input_key_management"></a> [key\_management](#input\_key\_management) | Configuration for Key Management Service | <pre>object({<br>    name                      = string<br>    use_hs_crypto             = optional(bool) # Will force data source to be used. If not true, will default to kms<br>    use_data                  = optional(bool)<br>    authorize_vpc_reader_role = optional(bool)<br>    resource_group_name       = optional(string) # Resource group for key management resources<br>  })</pre> | <pre>{<br>  "authorize_vpc_reader_role": true,<br>  "name": "kms"<br>}</pre> | no |
| <a name="input_keys"></a> [keys](#input\_keys) | List of keys to be created for the service | <pre>list(<br>    object({<br>      name            = string<br>      root_key        = optional(bool)<br>      payload         = optional(string)<br>      key_ring        = optional(string) # Any key_ring added will be created<br>      force_delete    = optional(bool)<br>      endpoint        = optional(string) # can be public or private<br>      iv_value        = optional(string) # (Optional, Forces new resource, String) Used with import tokens. The initialization vector (IV) that is generated when you encrypt a nonce. The IV value is required to decrypt the encrypted nonce value that you provide when you make a key import request to the service. To generate an IV, encrypt the nonce by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.<br>      encrypted_nonce = optional(string) # The encrypted nonce value that verifies your request to import a key to Key Protect. This value must be encrypted by using the key that you want to import to the service. To retrieve a nonce, use the ibmcloud kp import-token get command. Then, encrypt the value by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.<br>      policies = optional(<br>        object({<br>          rotation = optional(<br>            object({<br>              interval_month = number<br>            })<br>          )<br>          dual_auth_delete = optional(<br>            object({<br>              enabled = bool<br>            })<br>          )<br>        })<br>      )<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | `"icse"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions. | `string` | n/a | yes |
| <a name="input_secrets_manager"></a> [secrets\_manager](#input\_secrets\_manager) | Map describing an optional secrets manager deployment | <pre>object({<br>    use_secrets_manager = bool<br>    name                = optional(string)<br>    kms_key_name        = optional(string)<br>    resource_group_name = optional(string)<br>  })</pre> | <pre>{<br>  "use_secrets_manager": false<br>}</pre> | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | Service endpoints. Can be `public`, `private`, or `public-and-private` | `string` | `"private"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to apply to resources created by this module. | `list(string)` | `[]` | no |
| <a name="input_use_resource_group_ids"></a> [use\_resource\_group\_ids](#input\_use\_resource\_group\_ids) | OPTIONAL - Use resource group IDs instead of passing in existing resource group names. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config_failure"></a> [config\_failure](#output\_config\_failure) | configuration fail state for cos buckets containing unfound keys |
| <a name="output_cos_buckets"></a> [cos\_buckets](#output\_cos\_buckets) | List of COS bucket instances with shortname, instance\_shortname, name, id, crn, and instance id. |
| <a name="output_cos_instances"></a> [cos\_instances](#output\_cos\_instances) | List of COS resource instances with shortname, name, id, and crn. |
| <a name="output_cos_keys"></a> [cos\_keys](#output\_cos\_keys) | List of COS bucket instances with shortname, instance\_shortname, name, id, crn, and instance id. |
| <a name="output_cos_suffix"></a> [cos\_suffix](#output\_cos\_suffix) | Random suffix appended to COS resources. |
| <a name="output_key_management_crn"></a> [key\_management\_crn](#output\_key\_management\_crn) | CRN for KMS instance |
| <a name="output_key_management_guid"></a> [key\_management\_guid](#output\_key\_management\_guid) | GUID for KMS instance |
| <a name="output_key_management_name"></a> [key\_management\_name](#output\_key\_management\_name) | Name of key management service |
| <a name="output_key_rings"></a> [key\_rings](#output\_key\_rings) | Key rings created by module |
| <a name="output_keys"></a> [keys](#output\_keys) | List of names and ids for keys created. |
| <a name="output_secrets_manager_guid"></a> [secrets\_manager\_guid](#output\_secrets\_manager\_guid) | guid of secrets manager instance |
| <a name="output_secrets_manager_id"></a> [secrets\_manager\_id](#output\_secrets\_manager\_id) | id of secrets manager instance |
| <a name="output_secrets_manager_name"></a> [secrets\_manager\_name](#output\_secrets\_manager\_name) | Name of secrets manager instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->
