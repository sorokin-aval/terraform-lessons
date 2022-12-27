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
  common_tags   = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map      = merge(local.common_tags.locals)
  
  zone_name     = basename(dirname(get_terragrunt_dir()))
}

inputs   = {
  zone_id = lookup(dependency.zone.outputs.route53_zone_zone_id, local.zone_name)

  records = jsonencode([
    {
      name    = "sbc1"
      type    = "CNAME"
      ttl     = 3600
      records = ["ip-10-227-50-12.eu-central-1.compute.internal"]
    }
    # # {
    #   name    = "console-sh"
    #   type    = "A"
    #   ttl     = 3600
    #   records = ["10.226.148.6",]
    # },
  ])
}
