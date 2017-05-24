# Get request data and meta
$body = Get-Content $req -Raw | ConvertFrom-Json
$data = $body.data
$meta = $body.meta

Write-Output $body

$result = @{}
$result.id = $body.id
$result.RowKey = $body.id
$result.PartitionKey = $data.type
$result.requester = $meta.requester
$result.type = $data.type
$result.email = $data.attributes.email

$json = ConvertTo-Json -InputObject $result
Write-Output $json

Out-File -Encoding Ascii -FilePath $res -inputObject $json
