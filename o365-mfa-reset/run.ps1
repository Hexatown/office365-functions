# Get request data and meta
$requestBody = Get-Content $req -Raw | ConvertFrom-Json
$data = $requestBody.data
$meta = $requestBody.meta

$result = @{}
$result.requester = $meta.requester
$result.type = $data.type
$result.email = $data.attributes.email

$json = ConvertTo-Json -InputObject $result

Out-File -Encoding Ascii -FilePath $res -inputObject $json
