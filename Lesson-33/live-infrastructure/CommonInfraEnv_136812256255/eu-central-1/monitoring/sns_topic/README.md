<b>SNS Topic creation</b>

Terraform module used:
https://registry.terraform.io/modules/terraform-aws-modules/sns/aws/latest

To create SNS Topic: 
* copy one of the existing folders with terragrunt.hcl config within
* the name of the new directory will correspond to the name of the future newly created sns topic
* replace the required parameters in the inputs area of the terragrunt.hcl file: display_name, policy etc.
* from the terragrunt.hcl file directory, execute: terragrunt init; terragrunt plan; terragrunt apply
* to apply the command to multiple objects, go to the parent folder and run: terragrunt run-all init; terragrunt run-all plan; terragrunt run-all apply

<i>When executing the "terragrunt run-all" command to reduce the amount of used disk space (so that the aws terraform provider is not loaded separately for each object), you can execute the following commands (example): \
$ cd ua-avalaunch-terragrunt/live-infrastructure/CommonInfraEnv_136812256255/eu-central-1/monitoring/sns_topic \
$ export TERRAGRUNT_DOWNLOAD=$(pwd)/.terragrunt-cache \
$ export TF_PLUGIN_CACHE_DIR=$TERRAGRUNT_DOWNLOAD/.plugins</i>
