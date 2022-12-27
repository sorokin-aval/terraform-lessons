iam_role = local.account_vars.iam_role

include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git//.?ref=main"
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/baseline"
  mock_outputs = {
    ids = ["subnet-00000000000000000"]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name         = basename(get_terragrunt_dir())
}

dependency "cloudwatch_exporter_iam_role" {
  config_path = "../../iam/iam-assumable-role/CloudwatchExporterEC2Role"
  mock_outputs = {
    iam_instance_profile_name = "TemporaryDummyName"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

inputs = {
  #Set Image ID for your server here
  ami = "ami-0b8ebfb049f780f0b"

  #Set instance type for your server here
  instance_type = "c6i.xlarge"

  ebs_optimized        = true
  create_iam_role_ssm  = false
  iam_instance_profile = dependency.cloudwatch_exporter_iam_role.outputs.iam_instance_profile_name
  #Rules to allow access to server. In this example allowed access on port 8080 because application open this port
  sg_ingress_rules = [
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "TCP"
      cidr_blocks = ["10.0.0.0/8"]
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "TCP"
      cidr_blocks = ["10.0.0.0/8"]
    },
    {
      from_port   = 10050
      to_port     = 10050
      protocol    = "TCP"
      cidr_blocks = ["10.0.0.0/8"]
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "ICMP"
      cidr_blocks = ["10.0.0.0/8"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      cidr_blocks = ["10.0.0.0/8"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      cidr_blocks = ["10.0.0.0/8"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["10.0.0.0/8"]
    }
  ]
  sg_egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  name      = local.name
  subnet_id = dependency.vpc.outputs.app_subnets.ids[0]
  key_name  = "platformOps"
  tags = merge(local.common_tags.locals, {
    application_role = "Grafana and Cloudwatch-exporter",
    map-migrated     = "d-server-015rwu0jc1l0jd",
    MAPProjectid     = "MPE32598"
    Backup           = "Daily-7day-Retention"
  })
}
