locals {
    tags = merge(
        read_terragrunt_config(find_in_parent_folders("domain.hcl")).locals.tags,
        {
            "business:cost-center" = "524"
            "internet-faced"       = "true"
        }
    )
}
