dependency "vpc"              { config_path = find_in_parent_folders("vpc-info") }
dependency "instance_profile" { config_path = find_in_parent_folders("iam/role/instance") }
dependency "key_pair"         { config_path = find_in_parent_folders("key-pair/webpromo-devops-shared") }
dependency "sg"               { config_path = find_in_parent_folders("webpromo/sg/instance-${local.name}") }

dependencies {
  paths = [
    find_in_parent_folders("vpc-info"),
    find_in_parent_folders("iam/role/instance"),
    find_in_parent_folders("key-pair/webpromo-devops-shared"),
    find_in_parent_folders("sg/instance-${local.name}"),
  ]
}

iam_role = local.account_vars.iam_role

terraform {
  source = local.account_vars.sources_ec2_instance_wrap
}

locals {
  name             = "webpromo"
  subnet           = "app"
  monitoring_tier  = local.name
  instance_name    = local.name
  tags_map         = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags             = merge(local.tags_map, { application_role = title(local.name) })
}

inputs = {
  defaults = merge(
  {
      key_name               = dependency.key_pair.outputs.key_pair_key_name
      iam_instance_profile   = dependency.instance_profile.outputs.iam_instance_profile_name
      vpc_security_group_ids = ["${dependency.sg.outputs.security_group_id}"]
      enable_volume_tags     = true
      create                 = false
#      instance_type          = local.account_vars.webpromo_options.instance_type,
#      ami                    = local.account_vars.webpromo_options.ami,
      name                   = local.name,
      subnet_id              = dependency.vpc.outputs["${local.subnet}_subnets"].ids[0]

      metadata_options = {
            http_tokens = "required"
        }

        tags        = local.tags
        volume_tags = local.tags
    },
    local.account_vars["${local.name}_options"].defaults,
  )

  items = {
    "${local.name}-01" = merge(
      {
        create    = true
        name      = "${local.instance_name}-01"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[0]
      },
      try(local.account_vars["${local.instance_name}_options"].items["${local.name}-01"], {}),
    )
    "${local.name}-02" = merge(
      {
        name      = "${local.instance_name}-02"
        subnet_id = dependency.vpc.outputs["${local.subnet}_subnets"].ids[1]
      },
      try(local.account_vars["${local.instance_name}_options"].items["${local.name}-02"], {}),
    ),
  }
}