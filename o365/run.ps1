

#
# Query params           
#

$body = Get-Content $req -Raw -Encoding UTF8 | ConvertFrom-Json
$method = $req_params_method_name

. ".\o365\o365\mfa.ps1"


#
# Output
#

$result = @{}
$result.uuid = "Hello there"
$result.body = $body

$json = ConvertTo-Json -InputObject $result

Out-File -Encoding UTF8 -FilePath $res -inputObject $json