include { 
  path = find_in_parent_folders() 
}

iam_role = local.account_vars.iam_role

dependency "zone" {
  config_path = find_in_parent_folders("zone")
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.9.0"
}

locals {
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  #Tags in order ->(root folder)-> tags_common.hcl ->(current folder)-> tags.hcl
  common_tags   = read_terragrunt_config(find_in_parent_folders("tags_common.hcl"))
  local_tags    = read_terragrunt_config("tags.hcl", {locals = {tags={}}})
  tags_map      = merge(local.common_tags.locals.tags, local.local_tags.locals.tags)
  
  zone_name     = basename(dirname(get_terragrunt_dir()))
}

inputs   = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, local.zone_name)

  records = jsonencode([
    {
      name    = "db"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-147-221.eu-central-1.compute.internal"]
    },
    {
      name    = "hr-iis"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-149-242.eu-central-1.compute.internal"]
    },
    {
      name    = "hr-app"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-149-50.eu-central-1.compute.internal"]
    },
    {
      name    = "dbprod"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-147-137.eu-central-1.compute.internal"]
    },
    {
      name    = "hr-iis-prod"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-149-160.eu-central-1.compute.internal"]
    },
    {
      name    = "hr-app-prod"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-149-233.eu-central-1.compute.internal"]
    },
    {
      name    = "aws-jamfadcs"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-149-41.eu-central-1.compute.internal"]
    },
    {
      name    = "cobra-c"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-149-37.eu-central-1.compute.internal"]
    },    
    {
      name    = "o365integration"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-226-150-212.eu-central-1.compute.internal"]
    }   

    # {
    #   name    = "console-sh"
    #   type    = "A"
    #   ttl     = 3600
    #   records = ["10.226.148.6",]
    # },
  ])
}
