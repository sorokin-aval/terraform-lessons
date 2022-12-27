dependency "vpc"              { config_path = find_in_parent_folders("vpc-info") }
dependency "instance_profile" { config_path = find_in_parent_folders("iam/role/instance") }
dependency "key_pair"         { config_path = find_in_parent_folders("key-pair/raifsite-devops-shared") }

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
    find_in_parent_folders("iam/role/instance"),
    find_in_parent_folders("key-pair/raifsite-devops-shared"),
    find_in_parent_folders("sg/instance-${local.name}"),
  ]
}

terraform {
  source = local.account_vars.sources_ec2_instance
}

locals {
  name             = "maintenance-nginx"
  subnet           = "app"
  monitoring_tier  = local.name
  instance_name    = local.name
  tags_map         = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags             = merge(local.tags_map, { application_role = title(local.name) })
  user_data_locals  = read_terragrunt_config("instances.hcl").locals
  user_data_vars  = "service_name='${local.name}'\ndomain='${local.account_vars.domain}'\n\n"
  user_data    = base64encode(join("" , [local.user_data_locals.user_data_header, local.user_data_vars, local.user_data_locals.user_data_body]))
}

inputs = {
  key_name               = dependency.key_pair.outputs.key_pair_key_name
  iam_instance_profile   = dependency.instance_profile.outputs.iam_instance_profile_name
  vpc_security_group_ids = ["${dependency.sg.outputs.security_group_id}"]
  enable_volume_tags     = true
  create                 = "${local.account_vars.maintenance == "true" ? "true" : "false"}"
  instance_type          = local.account_vars.nginx_instance_type,
  ami                    = local.account_vars.nginx_ami,
  name                   = local.name,
  subnet_id              = dependency.vpc.outputs["${local.subnet}_subnets"].ids[0]
  user_data              = local.user_data

    metadata_options = {
        http_tokens = "required"
    }

    tags        = local.tags
    volume_tags = local.tags
}