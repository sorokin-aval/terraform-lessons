<powershell>
Set-TimeZone -Id "FLE Standard Time"
$instanceId = (invoke-webrequest http://169.254.169.254/latest/meta-data/instance-id -UseBasicParsing).content
$nameValue = (get-ec2tag -filter @{Name="resource-id";Value=$instanceid},@{Name="key";Value="Name"}).Value
$nameValue = $nameValue.Split(".")[0]

$pattern = "^(?![0-9]{1,15}$)[a-zA-Z0-9-]{1,15}$"
#Verify Name Value satisfies best practices for Windows hostnames
If ($nameValue -match $pattern)
    {Try
        {
[string]$SecretAD  = "prod/AD"
Import-Module AWSPowerShell
$SecretObj = (Get-SECSecretValue -SecretId $SecretAD)
[PSCustomObject]$Secret = ($SecretObj.SecretString  | ConvertFrom-Json)
$password   = $Secret.Password | ConvertTo-SecureString -asPlainText -Force
$username   = $Secret.UserID + "@" + $Secret.Domain
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -Domain $Secret.Domain -OUPath 'OU=MS-New,OU=Servers,OU=HO,DC=ms,DC=aval' -NewName $nameValue -Credential $Credential -Restart -Force
}
    Catch
        {$ErrorMessage = $_.Exception.Message
        Write-Output "Rename failed: $ErrorMessage"}}
Else
    {Throw "Provided name not a valid hostname. Please ensure Name value is between 1 and 15 characters in length and contains only alphanumeric or hyphen characters"}
</powershell>
