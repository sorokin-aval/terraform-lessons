include {
   path = "${find_in_parent_folders()}"
 }
 include "account" {
   path = find_in_parent_folders("account.hcl")
 }
 terraform {
   source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
 }
 dependencies {
   paths = ["../../iam_policy/ec2/", "../../iam_policy/lb/"]
 }
 locals {
   # Automatically load common variables from parent hcl
   project_vars   = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
   account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
   source_vars    = read_terragrunt_config(find_in_parent_folders("source.hcl"))
   # Extract out exact variables for reuse
   source_map     = local.source_vars.locals
   tags_map       = local.project_vars.locals.project_tags
   aws_account_id = local.account_vars.locals.aws_account_id
   module_tags    = {
     Role = local.role_name,
     Name = local.role_name
   }
   role_name = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}-team"
 }

 inputs = {
   create_role          = true
   role_name            = local.role_name
   max_session_duration = 43200
   description          = "This role for data-analytics-platform project"
   tags                 = merge(local.module_tags, local.tags_map)
   provider_id          = "arn:aws:iam::${local.aws_account_id}:saml-provider/RBI-PingFederate"
   role_policy_arns     = [
     "arn:aws:iam::${local.aws_account_id}:policy/${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}-ec2",
     "arn:aws:iam::${local.aws_account_id}:policy/${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}-lb"
   ]

 }
