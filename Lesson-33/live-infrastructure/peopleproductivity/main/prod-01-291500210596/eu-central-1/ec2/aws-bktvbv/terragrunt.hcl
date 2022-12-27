include { 
    path = find_in_parent_folders() 
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
    config_path = find_in_parent_folders("core-infrastructure/vpc-info") 
}

dependency "sg_infra" {
    config_path = find_in_parent_folders("sg/infra")
}
dependency "sg_ms-share" {
    config_path = find_in_parent_folders("sg/ms-share")
}
dependency "sg_egress-all" {
    config_path = find_in_parent_folders("sg/egress-all")
}

terraform {
    source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}

locals {
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags   = local.account_vars.locals.tags
  tags_map      = merge(local.common_tags)
  
  name = basename(get_terragrunt_dir())

  user_data = <<EOF
<powershell>
$instanceId = (invoke-webrequest http://169.254.169.254/latest/meta-data/instance-id -UseBasicParsing).content
$nameValue = (get-ec2tag -filter @{Name="resource-id";Value=$instanceid},@{Name="key";Value="Name"}).Value
$pattern = "^(?![0-9]{1,15}$)[a-zA-Z0-9-]{1,15}$"
#Verify Name Value satisfies best practices for Windows hostnames
If ($nameValue -match $pattern)
    {Try
        {
[string]$SecretAD  = "prod/AD"
Import-Module AWSPowerShell
$SecretObj = (Get-SECSecretValue -SecretId $SecretAD)
[PSCustomObject]$Secret = ($SecretObj.SecretString  | ConvertFrom-Json)
$password   = $Secret.Password | ConvertTo-SecureString -asPlainText -Force
$username   = $Secret.UserID + "@" + $Secret.Domain
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -Domain $Secret.Domain -OUPath 'OU=Branches_2016,OU=Servers_RD,DC=ms,DC=aval' -NewName $nameValue -Credential $Credential -Restart -Force
}
    Catch
        {$ErrorMessage = $_.Exception.Message
        Write-Output "Rename failed: $ErrorMessage"}}
Else
    {Throw "Provided name not a valid hostname. Please ensure Name value is between 1 and 15 characters in length and contains only alphanumeric or hyphen characters"}
</powershell>
EOF  

}

inputs = {
    name          = local.name
    ami           = "ami-0c2e8e3e554f8da89"
    instance_type = "t3.medium"
    attach_ebs    = true
    ebs_optimized = true
    ebs_size_gb   = 5
    ebs_type      = "gp3"
    ebs_availability_zone = "eu-central-1a"
    subnet_id     = dependency.vpc.outputs.db_subnets.ids[2]
    key_name      = "pnp-default-pem"
    tags          = local.tags_map
    iam_instance_profile = "DescribeTags-Secret"
    user_data     = local.user_data
    
    create_iam_role_ssm = true

    create_security_group_inline = false
    vpc_security_group_ids = [
        dependency.sg_infra.outputs.security_group_id,
        dependency.sg_ms-share.outputs.security_group_id,
        dependency.sg_egress-all.outputs.security_group_id,    
    ]
}
