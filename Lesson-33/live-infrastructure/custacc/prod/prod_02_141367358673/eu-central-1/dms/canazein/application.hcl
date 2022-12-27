locals {
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("project.hcl")).locals.tags,
    {
      "map-migrated" = "d-server-023fj481f4v237"
    }
  )
}