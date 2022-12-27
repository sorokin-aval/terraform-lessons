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

dependencies {
  paths = [
    find_in_parent_folders("vpc-info"),
    find_in_parent_folders("sg/instance-${local.name}"),
  ]
}

terraform {
  source = local.account_vars.sources_ec2_instance
}

locals {
  name             = "otp"
  subnet           = "app"
  monitoring_tier  = "passcode"
  tags_map         = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port         = local.account_vars.default_app_port
  tags             = merge(local.tags_map, { map-migrated = local.account_vars["tag_map_migrated_${local.name}"], application_role = title(local.name) })
  user_data_locals = read_terragrunt_config(find_in_parent_folders("_commons/ro/ec2/instance/instances.hcl")).locals
  user_data_vars   = "tier='${local.monitoring_tier}'\nservice_name='${local.name}'\nappdyn_conf_path_prefix='${local.account_vars.appdyn_conf_path_prefix}'\n\n"
  user_data        = join("" , [local.user_data_locals.user_data_header, local.user_data_vars, local.user_data_locals.user_data_body])
}


inputs = {

  defaults = merge(
    {
      key_name               = local.account_vars.ssh_key_name
      iam_instance_profile   = local.account_vars.iam_instance_profile_name
      vpc_security_group_ids = ["${dependency.sg.outputs.security_group_id}"]
      enable_volume_tags     = true

      metadata_options = {
        http_tokens = "required"
      }

      tags        = local.tags
      volume_tags = local.tags
      user_data   = local.user_data
    },
    local.account_vars["instances_${local.name}"].defaults,
  )

  items = {
    "${local.name}01" = merge(
      {
        name      = "${local.tags_map.env}-${lower(local.tags_map.System)}-${local.name}-01"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[0]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}01"], {}),
    )
    "${local.name}02" = merge(
      {
        create    = false
        name      = "${local.tags_map.env}-${lower(local.tags_map.System)}-${local.name}-02"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[1]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}02"], {}),
    ),
  }
}
