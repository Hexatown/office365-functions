# Get request data and meta
$body = Get-Content $req -Raw | ConvertFrom-Json
$data = $body.data
$meta = $body.meta

Write-Output $body

$result = @{}
$result.uuid = $meta.uuid
$result.RowKey = $meta.uuid
$result.PartitionKey = $data.type
$result.requester = $meta.requester
$result.type = $data.type
$result.name = $data.attributes.name
$result.email = $data.attributes.email
$result.owner = $data.attributes.owner

$json = ConvertTo-Json -InputObject $result
Write-Output $json

Out-File -Encoding Ascii -FilePath $res -inputObject $json
