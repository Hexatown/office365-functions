# Get request data and meta
$body = Get-Content $req -Raw | ConvertFrom-Json
$data = $requestBody.data
$meta = $requestBody.meta

$result = @{}
$result.id = $body.id
$output.RowKey = $body.id
$output.PartitionKey = $data.type
$result.requester = $meta.requester
$result.type = $data.type
$result.email = $data.attributes.email

$json = ConvertTo-Json -InputObject $result
Write-Output $json

Out-File -Encoding Ascii -FilePath $res -inputObject $json
