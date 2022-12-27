iam_role = local.account_vars.iam_role

include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

dependency "sns_topic" {
  config_path = "../../../sns_topic/ses_emails_monitoring"
}
dependency "opsgenie_sns_topic" {
  config_path = "../../../sns_topic/CloudWatchAlarmsToOpsgenie"
}

locals {
  # Automatically load common variables from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.common_tags.locals
  aws_account_id = local.account_vars.locals.aws_account_id
  specific_tags = {
    Name = "${basename(get_terragrunt_dir())}",
    application_role = "CloudWatch_metric_alarm"
    }
}

inputs = {
  actions_enabled = true
  alarm_actions = [
    dependency.sns_topic.outputs.sns_topic_id,
    dependency.opsgenie_sns_topic.outputs.sns_topic_id
  ]
  alarm_description = "https://docs.aws.amazon.com/ses/latest/dg/reputationdashboard-cloudwatch-alarm.html"
  alarm_name        = "${basename(get_terragrunt_dir())}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  dimensions                = {}
  evaluation_periods        = 1
  id                        = "Amazon SES: monitor overall sent emails per day"
  insufficient_data_actions = [dependency.opsgenie_sns_topic.outputs.sns_topic_id]
  metric_name               = "Send"
  metric_query              = []
  namespace                 = "AWS/SES"
  ok_actions                = [dependency.opsgenie_sns_topic.outputs.sns_topic_id]
  period                    = 86400
  statistic                 = "Sum"
  tags = merge(local.tags_map, local.specific_tags)
  threshold                 = 220000
  treat_missing_data        = "ignore"
}
