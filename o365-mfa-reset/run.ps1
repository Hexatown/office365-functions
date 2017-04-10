if ($triggerInput -eq $null){
    $res = "$PSScriptRoot\output.json"
    $triggerInput = "$PSScriptRoot\input.json"
}


$req = Get-Content $triggerInput -Raw
$requestBody =  ConvertFrom-Json -InputObject $req
$name = $requestBody.body.mailbox

Write-Output "Resetting password for $name"