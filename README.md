<!-- Update the title to match the module name and add a description -->
# Terraform IBM Module Template

<!-- UPDATE BADGE: Update the link for the badge below-->
[![Build Status](https://github.com/terraform-ibm-modules/terraform-ibm-module-template/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-module-template/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

<!-- Remove the content in this H2 heading after completing the steps -->

## Submit a new module

:+1::tada: Thank you for taking the time to contribute! :tada::+1:

This template repository exists to help you create Terraform modules for IBM Cloud.

The default structure includes the following files:

- `README.md`: A description of the module
- `main.tf`: The logic for the module
- `version.tf`: The required terraform and provider versions
- `variables.tf`: The input variables for the module
- `outputs.tf`: The values that are output from the module

For more information, see [Module structure](https://terraform-ibm-modules.github.io/documentation/#/module-structure) in the project documentation.

You can add other content to support what your module does and how it works. For example, you might add a `scripts/` directory that contains shell scripts that are run by a `local-exec` `null_resource` in the Terraform module.

Follow this process to create and submit a Terraform module.

### Create a repo from this repo template

1.  Create a repository from this repository template by clicking `Use this template` in the upper right of the GitHub UI.

    For more information about creating a repository from a template, see the [GitHub docs](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).
1.  Select `terraform-ibm-modules` as the owner.
1.  Enter a name for the module in format `terraform-ibm-<NAME>`, where `<NAME>` reflects the type of infrastructure that the module manages.

    Use hyphens as delimiters for names with multiple words (for example, terraform-ibm-`activity-tracker`).
1.  Provide a short description of the module.

    The description is displayed under the repository title on the [organization page](https://github.com/terraform-ibm-modules) and in the **About** section of the repository. Use the description to help users understand what your repo does by looking at the description.

### Clone the repo and set up your development environment

Locally clone the new repository and set up your development environment by completing the tasks in [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.

### Update the Terraform files

Implement the logic for your module by updating the `main.tf`, `version.tf`, `variables.tf`, and `outputs.tf` Terraform files. For more information, see [Creating Terraform on IBM Cloud templates](https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-create-tf-config).

### Create examples and tests

Add one or more examples in the `examples` directory that consume your new module, and configure tests for them in the `tests` directory.

### Update the content in the readme file

After you implement the logic for your module and create examples and tests, update this readme file in your repository by following these steps:

1.  Update the title heading and add a description about your module.
1.  Update the badge links.
1.  Remove all the content in this H2 heading section.
1.  Complete the [Usage](#usage), [Required IAM access policies](#required-iam-access-policies), and [Examples](#examples) sections. The [Requirements](#requirements) section is populated by a pre-commit hook.

### Commit your code and submit your module for review

1.  Before you commit any code, review [Contributing to the IBM Cloud Terraform modules project](https://terraform-ibm-modules.github.io/documentation/#/contribute-module) in the project documentation.
1.  Create a pull request for review.

### Post-merge steps
After the first PR for your module is merged, follow these post-merge steps:

1.  Create a PR to enable the upgrade test by removing the `t.Skip` line in `tests/pr_test.go`.

<!-- Remove the content in this previous H2 heading -->

## Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl

```

## Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

<!--
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

<!-- No permissions are needed to run this module.-->

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [Examples](examples)
<!-- END EXAMPLES HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.43.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_object_storage"></a> [cloud\_object\_storage](#module\_cloud\_object\_storage) | git://github.com/terraform-ibm-modules/terraform-ibm-icse-cos.git | n/a |
| <a name="module_encryption_key_map"></a> [encryption\_key\_map](#module\_encryption\_key\_map) | ./config_modules/list_to_map | n/a |
| <a name="module_key_management"></a> [key\_management](#module\_key\_management) | git://github.com/terraform-ibm-modules/terraform-ibm-icse-key-management.git | n/a |

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
| <a name="input_key_management"></a> [key\_management](#input\_key\_management) | Configuration for Key Management Service | <pre>object({<br>    name                      = string<br>    use_hs_crypto             = optional(bool) // Will force data source to be used. If not true, will default to kms<br>    use_data                  = optional(bool)<br>    authorize_vpc_reader_role = optional(bool)<br>    resource_group_name       = optional(string) // Resource group for key management resources<br>  })</pre> | <pre>{<br>  "authorize_vpc_reader_role": true,<br>  "name": "kms"<br>}</pre> | no |
| <a name="input_keys"></a> [keys](#input\_keys) | List of keys to be created for the service | <pre>list(<br>    object({<br>      name            = string<br>      root_key        = optional(bool)<br>      payload         = optional(string)<br>      key_ring        = optional(string) # Any key_ring added will be created<br>      force_delete    = optional(bool)<br>      endpoint        = optional(string) # can be public or private<br>      iv_value        = optional(string) # (Optional, Forces new resource, String) Used with import tokens. The initialization vector (IV) that is generated when you encrypt a nonce. The IV value is required to decrypt the encrypted nonce value that you provide when you make a key import request to the service. To generate an IV, encrypt the nonce by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.<br>      encrypted_nonce = optional(string) # The encrypted nonce value that verifies your request to import a key to Key Protect. This value must be encrypted by using the key that you want to import to the service. To retrieve a nonce, use the ibmcloud kp import-token get command. Then, encrypt the value by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.<br>      policies = optional(<br>        object({<br>          rotation = optional(<br>            object({<br>              interval_month = number<br>            })<br>          )<br>          dual_auth_delete = optional(<br>            object({<br>              enabled = bool<br>            })<br>          )<br>        })<br>      )<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
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

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->

## Contributing

You can report issues and request features for this module in the [terraform-ibm-issue-tracker](https://github.com/terraform-ibm-modules/terraform-ibm-issue-tracker/issues) repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
