### terragrunt.hcl

include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

terraform {
  #    source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git//?ref=main"
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}


locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  name = local.name
  # Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-06-09
  #      ami           = "ami-065deacbcaac64cf2"
  # Amazon Linux 2 Kernel 5.10 AMI 2.0.20220606.1 x86_64 HVM gp2
  ami = "ami-0a1ee2fb28fe05df3"
  # from sample - Error: creating EC2 Instance: AuthFailure: Not authorized for images: [ami-0c3687ac544e748e0] 
  #      ami           = "ami-0c3687ac544e748e0"

  instance_type = "t3.micro"
  ebs_optimized = true
  subnet_id     = dependency.vpc.outputs.app_subnets.ids[0]
  #  iam_instance_profile = "ssm-ec2-role"
  #     iam_instance_profile = "nifi_ec2_to_S3"
  #     create_iam_role_ssm = false
  aws_iam_role = "custacctst-tst-ssm"

  tags = merge(local.app_vars.locals.tags,
    { map-migrated = "d-server-00eqv9juq0ithf",
      #     Backup = "Daily-3day-Retention"
  })
  volume_tags = merge(local.app_vars.locals.tags,
    { map-migrated = "d-server-00eqv9juq0ithf",
      #     Backup = "Daily-3day-Retention"
  })


  user_data = <<-EOF
		#! /bin/bash
		yum install mc -y
      EOF

  sg_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
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

}

