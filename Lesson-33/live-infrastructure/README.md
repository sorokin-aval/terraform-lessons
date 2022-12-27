# Terragrunt Live Infrastructure
Live infrastructure built with Terragrunt using Terraform modules.

## Repository structure
The configuration has following directory structure:
```
root
└── RaifOnlineDev_628272282290
    └── eu-central-1
        ├── eks
        └── int-rds
```

In details:
1. Root directory with common configuration like terraform state settings. It has:
   * `account.hcl` - common settings of the account
   * `tags.hcl` - common tags that will be applied in the child configs
2. Region directory with resources. It has:
   * `region.hcl` - common values for specific region
   * directories with resources
3. Resource directory with `terragrunt.hcl` that use terraform modules from https://gitlab.devops.aval/sre/terraform-modules

## Features
* S3 Bucket backend for storing Terraform state
* DynamoDB as locking mechanism to avoid race condition with Terraform state
* Easy-to-change values and tags via dedicated files

## Usage
### Pre-requisites

1. Install [Terraform](https://www.terraform.io/) version `1.0.0` or newer and
   [Terragrunt](https://github.com/gruntwork-io/terragrunt) version `v0.29.2` or newer.
2. Configure your AWS credentials using one of the supported [authentication
   mechanisms](https://www.terraform.io/docs/providers/aws/#authentication).


### Deploying a single module
1. `cd` into the module's folder (e.g. `cd RaifOnlineDev_628272282290/eu-central-1/eks`).
2. Run `terragrunt plan` to see the changes you're about to apply.
3. If the plan looks good, run `terragrunt apply`.


### Deploying all modules in a region
1. `cd` into the region folder (e.g. `cd RaifOnlineDev_628272282290/us-east-1`).
2. Run `terragrunt plan-all` to see all the changes you're about to apply.
3. If the plan looks good, run `terragrunt apply-all`.