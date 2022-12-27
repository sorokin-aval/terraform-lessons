include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/is-card/nlb.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  target_groups = [
    { # IS-Card - index 6
      name             = "transit-db-is-card-1521"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets          = [{ target_id : dependency.db01-is-card.outputs.ec2_id, port : 1521 }]
    },
    { # IS-Card - index 7
      name             = "transit-db-is-card-1575"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets          = [{ target_id : dependency.db01-is-card.outputs.ec2_id, port : 1575 }]
    },
  ]
}