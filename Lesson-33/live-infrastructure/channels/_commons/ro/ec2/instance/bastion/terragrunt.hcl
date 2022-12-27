dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependency "sg" {
  config_path = find_in_parent_folders("sg/instance-${local.name}")
}

terraform {
  source = local.account_vars.sources_ec2_instance
}

iam_role = local.account_vars.iam_role

locals {
  name             = "bastion"
  subnet           = "app"
  tags_map         = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port         = local.account_vars.default_app_port
  tags             = merge(local.tags_map, { map-migrated = local.account_vars["tag_map_migrated_${local.name}"], application_role = title(local.name) })
}


inputs = {

  defaults = {
      key_name               = local.account_vars.ssh_key_name
      iam_instance_profile   = local.account_vars.iam_instance_profile_name
      vpc_security_group_ids = ["${dependency.sg.outputs.security_group_id}"]
      enable_volume_tags     = true

      metadata_options = {
        http_tokens = "required"
      }

      tags        = local.tags
      volume_tags = local.tags
    },

  items = {
    "${local.name}" = merge(
      {
        name      = "${local.tags_map.env}-${lower(local.tags_map.System)}-${local.name}"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[0]
      },
      try(local.account_vars["instances_${local.name}"].items["${local.name}"], {}),
    ),
  }
}
