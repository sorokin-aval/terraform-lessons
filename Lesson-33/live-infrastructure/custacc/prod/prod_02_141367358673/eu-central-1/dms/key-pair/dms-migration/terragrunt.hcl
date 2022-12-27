include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/core-infrastructure/key-pair.hcl")
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLfofOrDYgys2xNTrDLkRWF0STjGgA5FG4urxp/lumPQahc6p/IXaUJaXvKrEw8BhWzqqq4ph3FLiphubsgE6/1C6D8IwcgyyeKyscaJcyQ0ErMKtela1z1poATGDXWU3emZjYhFhjPHBrmKFUL1O4Keu5mtoib4Xd3pvLe2VgjiGVI7zyQESZ4VuarXnqDkH3IpiI2aBIOM+N0egvCgaidIALn5MnypGBUoPWbuwmK4+c0KcZhjy5dYjiQR4l3gku5AP0y2HpSLh5YqyrwETCjaajubiQgmjc6S4FHAOIikQRu7Cq3wyrVkew6UJRd0pd97jx8tOVVJQSuGPTUkit iuad1h5b@dms.hosts"
}