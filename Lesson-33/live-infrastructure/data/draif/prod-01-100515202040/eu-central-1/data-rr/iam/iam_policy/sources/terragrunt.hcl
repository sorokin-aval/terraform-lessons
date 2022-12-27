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
  s3_prefix    = "${local.project_vars.locals.resource_prefix}-${local.layer}"
}


inputs = {
  name        = "${local.project_vars.locals.project_prefix}-sources"
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
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_users/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_crd_changes_history/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_crd_changes/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_acc_info/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_acc_param/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_cards/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_bin_table/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_clients/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_categories/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_cards_jn/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_accounts/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_monitored_fields/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_card_groups/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_cond_accnt/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_branches/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_branch_accounts/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_cl_acct/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_acc_branch/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.izd_ccy_table/*",
                "arn:aws:s3:::${local.s3_prefix}-transmaster/ods/issuing2_0.issuing2_0.izd_ccy_conv_ex/*",
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
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/iscard.cardsglobal/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/ic.agreements/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/ic.cardkindclass/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/iscard.cardstatusclass/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/iscard.prefixclass/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/iscard.postingarch/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/iscard.cards/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/iscard.statusagrclass/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/ic.accounts/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/iscard.preperscards/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/iscard.conditclass/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/iscard.userclass/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/iscard.branchclass/*",
                "arn:aws:s3:::${local.s3_prefix}-iscard/ods/iscard.currencyclass/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.products_mapping/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.aux_gdwh_loadh/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.acctype_splt_bal_part_id/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.product_hierarchy_l1h/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.product_hierarchy_l2h/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.product_hierarchy_l3h/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.product_hierarchy_l4h/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.product_hierarchy_l5h/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.edits_list/*",
                "arn:aws:s3:::${local.s3_prefix}-ataccama/ods/rdm12.gpc_dealtype_dict/*"
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
