# proof of concept tested to retrieve FAWS information from Public Rackspace API
# requires existing user and API key with sufficient access to FAWS accounts - customer created

$userauth = "apitest" # user
$passauth = "REDACTED" # api key

# some ugly code not optimized to create request for the Identity API and retrieve a temporary token

$authbody = @{
            "auth" = @{
		      "RAX-KSKEY:apiKeyCredentials"=@{
              "username" = $userauth;
              "apiKey" = $passauth;
		        }
            }
        }
$authbody = $authbody | ConvertTo-Json

$authreq = Invoke-RestMethod -Uri https://identity.api.rackspacecloud.com/v2.0/tokens -Method Post -Body $authbody -ContentType application/json
$token = $authreq.access.token.id

# customer ID for Master account that above API user has access
$aws_master_account = "123456" 

# more not optimized code  that works

    $url = "https://accounts.api.manage.rackspace.com/v0/awsAccounts"

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-Auth-Token" , $token)
    $headers.Add("X-Tenant-Id", $aws_master_account)

        try {
            $query = Invoke-RestMethod -Uri $url -Method "Get" -Headers $headers -ContentType "application/json" -TimeoutSec 60 
            }
        catch {
            write-host "Some Error!"
        }

# output and some checks because currently ServiceLevel is ID only

foreach ($acc in $query.awsAccounts)
{
    
    if (($acc.serviceLevelId).Equals("902610ef3e2748a4a6a20866323e1774")) { $sl= "Aviator" }
    if (($acc.serviceLevelId).Equals("439cc3a473744806be5d37fccdfb4304")) { $sl= "Navigator" }
    $acc | add-member -MemberType NoteProperty -Name ServiceLevel -Value ($sl)
} 

$query.awsAccounts | Select-Object name, servicelevel | Export-Csv awsaccounts.csv -NoTypeInformation
