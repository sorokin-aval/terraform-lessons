terraform {
  source = local.account_vars.locals.sources["host"]
}

iam_role = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/terraform-role"

# Include Network 
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }

# Include Security Groups
dependency "sg_outgoing" { config_path = find_in_parent_folders("core-infrastructure/sg/outgoing") }
dependency "sg_ssh" { config_path = find_in_parent_folders("core-infrastructure/sg/ssh") }
dependency "sg_dms_dc" { config_path = find_in_parent_folders("sg/dms_dc") }
dependency "sg_admin" { config_path = find_in_parent_folders("sg/access_admin") }
dependency "sg_phisical" { config_path = find_in_parent_folders("sg/access_phisical") }
dependency "sg_web" { config_path = find_in_parent_folders("sg/access_web") }
dependency "sg_jboss_phisical" { config_path = find_in_parent_folders("sg/jboss_phisical") }
dependency "sg_jboss_vdi" { config_path = find_in_parent_folders("sg/jboss_vdi") }

# Include key_name
dependency "key" { config_path = find_in_parent_folders("key-pair/dms-migration") }


locals {
  account_vars                 = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map                     = read_terragrunt_config("application.hcl")
  name                         = basename(get_terragrunt_dir())
  subnet_id                    = "${substr(local.account_vars.locals.ec2[local.name].availability_zone, -1, -2) == "a" ? "1" : "0"}"
  user_data_locals             = read_terragrunt_config(find_in_parent_folders("instances.hcl"))
}


inputs = {
  name                         = "${upper(local.tags_map.locals.tags["business:product-project"])}-${local.name}"
  ami                          = local.account_vars.locals.platform_ami
  instance_type                = local.account_vars.locals.ec2[local.name].instance_type
  availability_zone            = local.account_vars.locals.ec2[local.name].availability_zone
  tags                         = merge(local.tags_map.locals.tags, { product = "DMS-LCA" })
  volume_tags                  = merge(local.tags_map.locals.tags, { product = "DMS-LCA" })
  subnet_id                    = dependency.vpc.outputs.app_subnets.ids[local.subnet_id]
  key_name                     = dependency.key.outputs.key_pair_name

  create_security_group_inline = false
  vpc_security_group_ids       = [
    dependency.sg_outgoing.outputs.security_group_id,
    dependency.sg_ssh.outputs.security_group_id,
    dependency.sg_dms_dc.outputs.security_group_id,
    dependency.sg_admin.outputs.security_group_id,
    dependency.sg_phisical.outputs.security_group_id,
    dependency.sg_web.outputs.security_group_id,
    dependency.sg_jboss_phisical.outputs.security_group_id,
    dependency.sg_jboss_vdi.outputs.security_group_id
  ]
  root_block_device            = [{ volume_size = "10", volume_type = "gp3", encrypted = true, delete_on_termination = false }]
  # EBS
  aws_ebs_block_device = {
    vol = {
      device_name              = "/dev/sdh"
      volume_size              = local.account_vars.locals.ec2[local.name].ebs_size_gb
      encrypted                = true
      delete_on_termination    = false
    }
  }

  user_data                    = join("" , [local.user_data_locals.locals.user_data_header, "project='${lower(local.tags_map.locals.tags["business:product-project"])}'\nname='${local.name}'\ndevice_name='/dev/sdh'\n\n", local.user_data_locals.locals.user_data_body ])

}