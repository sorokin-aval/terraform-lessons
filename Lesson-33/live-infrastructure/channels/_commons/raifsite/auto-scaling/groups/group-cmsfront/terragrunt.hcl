dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependency "sg" {
  config_path = find_in_parent_folders("sg/instance-${local.name}")

  mock_outputs = {
    security_group_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "target_groups_pub_alb" {
  config_path = find_in_parent_folders("lb/public-alb")

  mock_outputs = {
    target_group_arns = "temporary-arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "target_groups_int_alb" {
  config_path = find_in_parent_folders("lb/raifsite-internal-alb")

  mock_outputs = {
    target_group_arns = "temporary-arn"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}


dependency "instance_profile" { config_path = find_in_parent_folders("iam/role/instance") }
dependency "key_pair"         { config_path = find_in_parent_folders("ec2/key-pair/raifsite-devops-shared") }

dependencies {
  paths = [
    find_in_parent_folders("vpc-info"),
    find_in_parent_folders("sg/instance-${local.name}"),
    find_in_parent_folders("iam/role/instance"),
    find_in_parent_folders("ec2/key-pair/raifsite-devops-shared"),
  ]
}

terraform {
  source = local.account_vars.sources_auto_scaling_group
}

iam_role = local.account_vars.iam_role

locals {
  name         = "cmsfront"
  subnet       = "app"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags         = merge(local.tags_map, { map-migrated = local.account_vars["tag_map_migrated_${local.name}"], application_role = title(local.name) })
  user_data_locals  = read_terragrunt_config("instances.hcl").locals
  user_data_vars  = "service_name='${local.name}'\n\n"
  user_data    = base64encode(join("" , [local.user_data_locals.user_data_header, local.user_data_vars, local.user_data_locals.user_data_body]))
}

inputs = {
  name			                = local.name
  key_name                  = dependency.key_pair.outputs.key_pair_key_name
  iam_instance_profile_name = dependency.instance_profile.outputs.iam_instance_profile_name
  enable_volume_tags        = true
  health_check_type         = "EC2"
  min_size                  = local.account_vars.cmsfront_autoscaling_options.min_size
  max_size                  = local.account_vars.cmsfront_autoscaling_options.max_size
  desired_capacity          = local.account_vars.cmsfront_autoscaling_options.desired_capacity
  wait_for_capacity_timeout = local.account_vars.cmsfront_autoscaling_options.wait_for_capacity_timeout
  instance_type             = local.account_vars.cmsfront_autoscaling_options.instance_type
  image_id                  = local.account_vars.cmsfront_autoscaling_options.instance_ami
  target_group_arns         = concat("${dependency.target_groups_pub_alb.outputs.target_group_arns}", "${dependency.target_groups_int_alb.outputs.target_group_arns}")
  target_group_arns         = concat("${local.account_vars.pub_cmsfront_sales_tg_arn}", "${local.account_vars.pub_cmsfront_main_tg_arn}", "${local.account_vars.int_cmsfront_admin_tg_arn}", "${local.account_vars.int_cmsfront_main_tg_arn}")
  termination_policies      = ["NewestInstance"]
  user_data                   = local.user_data
  launch_template_name        = local.name
  launch_template_description = "Launch template from CMSFront Auto Scaling Group"
  update_default_version      = true
  tag_specifications = [
    {
      resource_type = "instance"
      tags          = merge(
        local.tags_map,
        {
          map-migrated        = local.account_vars["tag_map_migrated_${local.name}"],
          application_role    = title(local.name),
          ami-policy          = local.account_vars.tag_ami_policy_cmsfront,
          ami-retention-count = local.account_vars.tag_ami_retention_count_cmsfront,
          ami-expiration-days = local.account_vars.tag_ami_expiration_days_cmsfront
        },
      )
    },
    {
      resource_type = "volume"
      tags          = local.tags
    },
  ]

  scaling_policies = {
    avg-cpu-policy-greater-than-80 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 600
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 80.0
      }
    }
  }

  metadata_options = {
    http_tokens               = "required"
    }

  network_interfaces = [
	{
    delete_on_termination = true
    description           = "eth0"
    device_index          = 0
    security_groups       = ["${dependency.sg.outputs.security_group_id}"]
  }
  ]

  tags        = local.tags
  volume_tags = local.tags
  vpc_zone_identifier = dependency.vpc.outputs["${local.subnet}_subnets"].ids
}
