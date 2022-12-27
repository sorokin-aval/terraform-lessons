locals {
  tags = merge(
    read_terragrunt_config(find_in_parent_folders("project.hcl")).locals.tags,
    {
      "map-migrated" = "d-server-02wf556o8y36df"
    }
  )
}