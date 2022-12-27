include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out exact variables for reuse
  source_map = local.source_vars.locals
  tags_map   = merge(local.project_vars.locals.project_tags, { Name = "barstat-db.data.rbua" })
  name       = "${local.tags_map.Project}-${basename(get_terragrunt_dir())}.${local.tags_map.Domain}.${local.tags_map.Nwu}"

}

inputs = {
  name              = local.name
  ami               = "ami-0e40d3ca36c92b3d1"
  instance_type     = "r5.large"
  ebs_optimized     = true
  subnet_id         = dependency.vpc.outputs.db_subnets.ids[0]
  private_ip        = "10.226.155.82"
  availability_zone = "eu-central-1a"
  key_name          = "platformOps"
  tags              = local.tags_map
  issue_certificate = false
  root_block_device = [
    {
      delete_on_termination = false
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 125
      iops                  = 3000
      volume_size           = 100
      snapshot_id           = "snap-037149cf375ebb388"
    }
  ]
  ebs_block_device = [
    {
      device_name           = "/dev/sdf"
      volume_type           = "gp3"
      volume_size           = 100
      throughput            = 125
      snapshot_id           = "snap-0619a2643b523ad4e"
      encrypted             = true
      delete_on_termination = false
      kms_key_id            = "arn:aws:kms:eu-central-1:665998680203:key/64f5d8b9-f80b-4a15-b11f-d5fb47e48d46"
    }
  ]
  sg_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Only import purpose"
    }
  ]
  sg_egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "This rules allows all outbound traffic"
    }
  ]
}
