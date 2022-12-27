dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }
dependency "sg"  { config_path = find_in_parent_folders("sg/instance-cmsfront") }

terraform { source = local.account_vars.sources_sg }

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-EFSCMSFront"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  name        = local.name
  description = "Security group for the CMSFront EFS"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      name        = "EFS"
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "Access from app subnets"
      cidr_blocks = local.account_vars.tier1_subnets
    }
  ]
}
