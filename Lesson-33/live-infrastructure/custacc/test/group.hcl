#Custacc
locals {
    tags = merge(
        read_terragrunt_config(find_in_parent_folders("domain.hcl")).locals.tags,
        {
            "security:environment" = "Test"
        }
    )
}
