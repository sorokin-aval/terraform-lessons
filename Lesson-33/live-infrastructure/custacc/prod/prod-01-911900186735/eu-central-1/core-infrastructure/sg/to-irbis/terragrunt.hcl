#  Custacc
include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
  #  config_path = "../../core-infrastructure/vpc-info/"
}


terraform {
  source = local.account_vars.locals.sources["sg"]
  #  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
}

locals {

  name        = basename(get_terragrunt_dir())
  description = "security group for IRBIS servers access"

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))

}

#object-group service to-IRBIS
#service-object tcp range 1098 1099
#service-object tcp range 1298 1299
#service-object tcp range 1397 1399
#service-object tcp range 1498 1499
#service-object tcp eq 2035
#service-object tcp range 3351 4933
#service-object tcp eq 7904
#service-object tcp eq 8083
#service-object tcp eq 8443
#service-object tcp eq 10097
#service-object tcp eq 10297
#service-object tcp eq 10397
#service-object tcp eq 10497


inputs = {
  name        = local.name
  description = local.description

  use_name_prefix = false
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = merge(local.app_vars.locals.tags, {})

  ingress_with_cidr_blocks = [
    {
      from_port   = 1098
      to_port     = 1099
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 1298
      to_port     = 1299
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 1397
      to_port     = 1399
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 1498
      to_port     = 1499
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 2035
      to_port     = 2035
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 3351
      to_port     = 4933
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 7904
      to_port     = 7904
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 8083
      to_port     = 8083
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 10097
      to_port     = 10097
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 10297
      to_port     = 10297
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 10397
      to_port     = 10397
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    },
    {
      from_port   = 10497
      to_port     = 10497
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    }
  ]

  egress_with_cidr_blocks = [
    {
      name        = "All"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
