# Route53 conifgurations for `RBUA_Technology_Prod` - `592760410760`

Here you can find terragrunt configuration for:

- `prod.rbua-zones` directory contains all definitions for all production zones
- `cmd.prod.rbua-entries` directory contains configurations for `*.cmd.prod.rbua` dns entries
- `infra.prod.rbua-entries` directory contains configurations for `*.infra.prod.rbua` dns entries. Infra zone contain
  infrastructure tools

## How to apply configurations

### Zone creation

If you need to create additional route53 zone please go to `prod.rbua-zones`
If you need some zone which is different from `prod.rbua-zones` than please create separate folder with all
configurations

### DNS entries

If you need to create some dns entry in zone cmd, infra or so just find directory with `*-entries` pattern and adjust it
