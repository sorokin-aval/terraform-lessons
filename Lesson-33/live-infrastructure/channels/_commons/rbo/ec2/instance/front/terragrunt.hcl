dependency "vpc"              { config_path = find_in_parent_folders("vpc-info") }
dependency "instance_profile" { config_path = find_in_parent_folders("iam/role/instance") }
dependency "key_pair"         { config_path = find_in_parent_folders("key-pair/main") }

dependency "sg" {
  config_path = find_in_parent_folders("sg/instance-${local.name}")

  mock_outputs = {
    security_group_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

terraform {
  source = local.account_vars.sources_ec2_instance
}

iam_role = local.account_vars.iam_role

locals {
  name             = "front"
  subnet           = "lb"
  monitoring_tier  = local.name
  instance_name    = "${local.tags_map.env}-${lower(local.tags_map.System)}-${local.name}"
  tags_map         = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port         = local.account_vars.default_app_port
  user_data_locals = read_terragrunt_config(find_in_parent_folders("_commons/rbo/ec2/instance/instances.hcl")).locals
  user_data_vars   = "tier='${local.monitoring_tier}'\nservice_name='${local.name}'\nconf_path_prefix='${local.account_vars.appdyn_conf_path_prefix}'\n\n"
  user_data        = join("" , [local.user_data_locals.user_data_header, local.user_data_vars, local.user_data_locals.user_data_body])
  tags = merge(
    local.tags_map,
    {
      map-migrated        = local.account_vars["tag_map_migrated_${local.name}"],
      application_role    = title(local.name),
      ami-policy          = local.account_vars.tag_ami_policy_app,
      ami-retention-count = local.account_vars.tag_ami_retention_count_app,
      ami-expiration-days = local.account_vars.tag_ami_expiration_days_app
    },
    try(local.account_vars.tag_schedule, "") != "" ? { Schedule = local.account_vars.tag_schedule } : {}
  )
}

inputs = {

  defaults = merge(
    {
      key_name               = dependency.key_pair.outputs.key_pair_key_name
      iam_instance_profile   = dependency.instance_profile.outputs.iam_instance_profile_name
      vpc_security_group_ids = ["${dependency.sg.outputs.security_group_id}"]
      enable_volume_tags     = true

      metadata_options = {
        http_tokens = "required"
      }

      tags        = local.tags
      volume_tags = local.tags
      user_data   = local.user_data
      create      = false
    },
    local.account_vars["instances_${local.name}"].defaults,
  )

  items = {
    "${local.name}01" = merge(
      {
        create    = true
        name      = "${local.instance_name}-01"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[0]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}01"], {}),
    )
    "${local.name}02" = merge(
      {
        name      = "${local.instance_name}-02"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[1]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}02"], {}),
    ),
    "${local.name}03" = merge(
      {
        name      = "${local.instance_name}-03"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[0]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}03"], {}),
    )
    "${local.name}04" = merge(
      {
        name      = "${local.instance_name}-04"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[1]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}04"], {}),
    ),
    "${local.name}05" = merge(
      {
        name      = "${local.instance_name}-05"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[0]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}05"], {}),
    ),
    "${local.name}06" = merge(
      {
        name      = "${local.instance_name}-06"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[1]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}06"], {}),
    ),
    "${local.name}07" = merge(
      {
        name      = "${local.instance_name}-07"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[0]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}07"], {}),
    )
    "${local.name}08" = merge(
      {
        name      = "${local.instance_name}-08"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[1]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}08"], {}),
    ),
    "${local.name}09" = merge(
      {
        name      = "${local.instance_name}-09"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[0]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}09"], {}),
    ),
    "${local.name}10" = merge(
      {
        name      = "${local.instance_name}-10"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[1]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}10"], {}),
    ),
  }
}
