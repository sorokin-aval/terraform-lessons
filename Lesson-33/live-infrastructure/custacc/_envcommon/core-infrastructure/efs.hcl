terraform {
  source = local.account_vars.locals.sources["efs"]
}

iam_role = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/terraform-role"

# Include Network 
dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }


locals {
  account_vars                        = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region                              = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  tags_map                            = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  name                                = basename(get_terragrunt_dir())
}


inputs = {
  name			                          = local.name
  vpc_id		                          = dependency.vpc.outputs.vpc_id.id
  region		                          = local.region.locals.aws_region
  subnets		                          = dependency.vpc.outputs["app_subnets"].ids
  encrypted		                        = true
  create_security_group               = true
  security_group_description          = "${upper(local.tags_map.locals.tags["business:product-project"])}: EFS Security Group for ${title(local.name)}"
  transition_to_ia                    = [ "AFTER_7_DAYS" ]
  transition_to_primary_storage_class = [ "AFTER_1_ACCESS" ]
  tags                                = local.tags_map.locals.tags
}