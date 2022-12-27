include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/tm/nlb.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  target_groups = [
    { # TM - index 6
      name             = "transit-db-tm-1521"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets          = [{ target_id : dependency.db01-tm.outputs.ec2_id, port : 1521 }]
    },
    { # TM - index 7
      name             = "transit-db-tm-1575"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets          = [{ target_id : dependency.db01-tm.outputs.ec2_id, port : 1575 }]
    },
  ]
}