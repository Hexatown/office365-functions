# Get request data and meta
$body = Get-Content $req -Raw | ConvertFrom-Json
$data = $body.data
$meta = $body.meta

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
