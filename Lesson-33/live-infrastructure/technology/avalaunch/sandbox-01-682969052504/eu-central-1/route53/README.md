# Route53 conifgurations for `RBUA_Sandbox` - `682969052504`

Here you can find terragrunt configuration for:

- `uat.rbua-zones` directory contains all definitions for all uat entries

## How to apply configurations

### Zone creation

If you need to create additional route53 zone please go to `uat.rbua-zones`
If you need some zone which is different from `uat.rbua-zones` than please create separate folder with all configurations

### DNS entries

If you need to create some dns entry in zone cmd, infra or so just find directory with `*-entries` pattern and adjust it