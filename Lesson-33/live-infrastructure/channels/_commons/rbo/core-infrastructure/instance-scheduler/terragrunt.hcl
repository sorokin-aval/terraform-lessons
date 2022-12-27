terraform {
  source = "tfr://registry.terraform.io/cloudposse/cloudformation-stack/aws//.?version=${local.cf_stack_module_version}"
}

locals {
  tags_map                = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars            = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  scheduler_version       = "v1.4.1"
  cf_stack_module_version = "0.7.1"
}

iam_role = local.account_vars.iam_role

inputs = {
  name         = "instance-scheduler"
  template_url = "https://s3.amazonaws.com/solutions-reference/aws-instance-scheduler/${local.scheduler_version}/aws-instance-scheduler.template"
  parameters = {
    TagName                     = "Schedule"
    ScheduledServices           = "Both"
    ScheduleRdsClusters         = "Yes"
    CreateRdsSnapshot           = "No"
    Regions                     = ""
    DefaultTimezone             = "Europe/Kiev"
    CrossAccountRoles           = ""
    ScheduleLambdaAccount       = "Yes"
    SchedulerFrequency          = "5"
    MemorySize                  = 128
    UseCloudWatchMetrics        = "Yes"
    Trace                       = "Yes"
    EnableSSMMaintenanceWindows = "Yes"
    LogRetentionDays            = 30
    StartedTags                 = "ec2autostartstop=Started on {year}-{month}-{day} at {hour}:{minute} {timezone}"
    StoppedTags                 = "ec2autostartstop=Stopped on {year}-{month}-{day} at {hour}:{minute} {timezone}"
  }

  capabilities = ["CAPABILITY_IAM"]
  tags         = local.tags_map # Neither the tag keys nor the tag values will be modified by this module.
}
