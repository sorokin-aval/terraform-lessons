include {
  path = "${find_in_parent_folders()}"
}
iam_role = local.account_vars.iam_role

include "account" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map   = local.source_vars.locals
  tags_map     = local.project_vars.locals.project_tags
  layer        = "raw"
  s3_prefix    = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.layer}"
}


inputs = {
  name        = "${local.tags_map.Nwu}-${local.tags_map.Tech_domain}-sources"
  path        = "/"
  description = "${local.tags_map.Project}-sources policy. Created with Terragrunt. Used to grant access to sources for project"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "01getsources",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
	              "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.*/*",
	              "arn:aws:s3:::${local.s3_prefix}-riskdata/ods/loxon.out_gdwh_deal/DPD/*",
                "arn:aws:s3:::${local.s3_prefix}-b2/ods/creator.*/*",
                "arn:aws:s3:::${local.s3_prefix}-orion/ods/orion.crd_dca/*",
                "arn:aws:s3:::${local.s3_prefix}-orion/ods/orion.crd_dcrl/*",
                "arn:aws:s3:::${local.s3_prefix}-orion/ods/orion.crd_prt/*",
                "arn:aws:s3:::${local.s3_prefix}-orion/ods/orion.crd_cbtm/*",
                "arn:aws:s3:::${local.s3_prefix}-orion/ods/orion.crd_cbl/*",
                "arn:aws:s3:::${local.s3_prefix}-orion/ods/orion.crd_cdl/*",
                "arn:aws:s3:::${local.s3_prefix}-clc/ods/public.t_statement_aud/*",
                "arn:aws:s3:::${local.s3_prefix}-cmd/ods/cmd.rba_links/*",
                "arn:aws:s3:::${local.s3_prefix}-cmd/ods/cmd.customer/*",
                "arn:aws:s3:::${local.s3_prefix}-cmd/ods/cmd.profile_person/*",
                "arn:aws:s3:::${local.s3_prefix}-cmd/ods/cmd.address/*",
                "arn:aws:s3:::${local.s3_prefix}-cmd/ods/cmd.norkom/*",
                "arn:aws:s3:::${local.s3_prefix}-cmd/ods/cmd.profile_legal/*",
                "arn:aws:s3:::${local.s3_prefix}-cmd/ods/cmd.cust_echannel/*",
                "arn:aws:s3:::${local.s3_prefix}-cmd/archive/cmd.profile_legal/*",
                "arn:aws:s3:::${local.s3_prefix}-vicont/ods/vicont.dbo.comval/*",
                "arn:aws:s3:::${local.s3_prefix}-vicont/ods/vicont.dbo.crncy/*",
                "arn:aws:s3:::${local.s3_prefix}-vicont/ods/vicont.dbo.ls/*",
                "arn:aws:s3:::${local.s3_prefix}-vicont/ods/vicont.dbo.trt/*",
                "arn:aws:s3:::${local.s3_prefix}-irbis/ods/irbis_ac.dbo.ounit/*",
                "arn:aws:s3:::${local.s3_prefix}-irbis/ods/irbis_ac.dbo.ounos/*",
                "arn:aws:s3:::${local.s3_prefix}-irbis/ods/irbis_ac.dbo.parti/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.products_mapping/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.*/*"
            ]
        },
        {
            "Sid": "02listsources",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.s3_prefix}-transmaster",
                "arn:aws:s3:::${local.s3_prefix}-riskdata",
                "arn:aws:s3:::${local.s3_prefix}-b2",
                "arn:aws:s3:::${local.s3_prefix}-orion",
                "arn:aws:s3:::${local.s3_prefix}-clc",
                "arn:aws:s3:::${local.s3_prefix}-cmd",
                "arn:aws:s3:::${local.s3_prefix}-vicont",
                "arn:aws:s3:::${local.s3_prefix}-irbis",
                "arn:aws:s3:::${local.s3_prefix}-iscard",
                "arn:aws:s3:::${local.s3_prefix}-ataccama"
            ]
        }
    ]
}
EOF

  tags = local.tags_map

}
