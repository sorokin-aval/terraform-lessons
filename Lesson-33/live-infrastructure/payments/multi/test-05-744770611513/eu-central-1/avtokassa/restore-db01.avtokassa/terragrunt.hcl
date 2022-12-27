include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/${basename(dirname(get_terragrunt_dir()))}/db.hcl")
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  subnet   = "LZ-RBUA_Payments_*-RestrictedA"
  zone     = "eu-central-1a"
  ami = "ami-0939b7be6d616fdf1"

  ebs_block_device = [
    {
      device_name = "/dev/sdb"
      volume_size = "450"
      volume_type = "gp3"
    },
    {
      device_name = "/dev/sdf"
      volume_size = "100"
      volume_type = "gp3"
    },
    {
      device_name = "/dev/sdg"
      volume_size = "50"
      volume_type = "gp3"
    },
    {
      device_name = "/dev/sdh"
      volume_size = "50"
      volume_type = "gp3"
    }
  ]

  ingress = [
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "commvault" },
  ]
  egress = [
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.app_subnet_cidr_blocks, description : "commvault" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault-ro"], description : "comm-vault-ro" },
  ]
}
